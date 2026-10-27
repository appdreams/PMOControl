-- Every Auth identity gets a non-empty profile label. Auth metadata is used only
-- as a display suggestion; users can replace it through their own profile RPC.
ALTER TABLE public.user_profiles ADD COLUMN profile_complete BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE public.user_profiles AS up
SET display_name = pg_catalog.left(
      COALESCE(
        NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'full_name'),''),
        NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'name'),''),
        NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'display_name'),''),
        NULLIF(pg_catalog.btrim(up.display_name),''),
        NULLIF(pg_catalog.split_part(COALESCE(u.email,''),'@',1),''),
        'Membro '||pg_catalog.left(u.id::TEXT,8)
      ),120),
    profile_complete = (
      NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'full_name'),'') IS NOT NULL OR
      NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'name'),'') IS NOT NULL OR
      NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'display_name'),'') IS NOT NULL OR
      NULLIF(pg_catalog.btrim(up.display_name),'') IS NOT NULL
    ),
    updated_at = pg_catalog.now()
FROM auth.users AS u
WHERE u.id=up.user_id;

INSERT INTO public.user_profiles(user_id,display_name,profile_complete)
SELECT u.id,
  pg_catalog.left(COALESCE(
    NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'full_name'),''),
    NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'name'),''),
    NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'display_name'),''),
    NULLIF(pg_catalog.split_part(COALESCE(u.email,''),'@',1),''),
    'Membro '||pg_catalog.left(u.id::TEXT,8)
  ),120),
  NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'full_name'),'') IS NOT NULL OR
  NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'name'),'') IS NOT NULL OR
  NULLIF(pg_catalog.btrim(u.raw_user_meta_data->>'display_name'),'') IS NOT NULL
FROM auth.users AS u
LEFT JOIN public.user_profiles AS up ON up.user_id=u.id
WHERE up.user_id IS NULL
ON CONFLICT (user_id) DO NOTHING;

ALTER TABLE public.user_profiles ALTER COLUMN display_name SET NOT NULL;
ALTER TABLE public.user_profiles DROP CONSTRAINT user_profiles_display_name_length;
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_display_name_length
  CHECK (display_name=pg_catalog.btrim(display_name) AND pg_catalog.char_length(display_name) BETWEEN 1 AND 120);

CREATE OR REPLACE FUNCTION private.create_user_profile_from_auth()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=''
AS $function$
DECLARE
  v_metadata_name TEXT;
  v_display_name TEXT;
BEGIN
  v_metadata_name:=COALESCE(
    NULLIF(pg_catalog.btrim(NEW.raw_user_meta_data->>'full_name'),''),
    NULLIF(pg_catalog.btrim(NEW.raw_user_meta_data->>'name'),''),
    NULLIF(pg_catalog.btrim(NEW.raw_user_meta_data->>'display_name'),'')
  );
  v_display_name:=pg_catalog.left(COALESCE(
    v_metadata_name,
    NULLIF(pg_catalog.split_part(COALESCE(NEW.email,''),'@',1),''),
    'Membro '||pg_catalog.left(NEW.id::TEXT,8)
  ),120);
  INSERT INTO public.user_profiles(user_id,display_name,profile_complete)
  VALUES(NEW.id,v_display_name,v_metadata_name IS NOT NULL)
  ON CONFLICT(user_id) DO NOTHING;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION private.create_user_profile_from_auth() FROM PUBLIC,anon,authenticated,service_role;
DROP TRIGGER IF EXISTS on_auth_user_created_profile ON auth.users;
CREATE TRIGGER on_auth_user_created_profile
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION private.create_user_profile_from_auth();

CREATE OR REPLACE FUNCTION private.get_my_profile()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=''
AS $function$
DECLARE v_actor UUID:=auth.uid(); v_profile public.user_profiles%ROWTYPE;
BEGIN
  IF v_actor IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
  SELECT * INTO v_profile FROM public.user_profiles WHERE user_id=v_actor;
  IF NOT FOUND THEN RAISE EXCEPTION 'User profile unavailable' USING ERRCODE='42501'; END IF;
  RETURN pg_catalog.jsonb_build_object('displayName',v_profile.display_name,'complete',v_profile.profile_complete);
END;
$function$;

CREATE OR REPLACE FUNCTION private.update_my_profile(p_display_name TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=''
AS $function$
DECLARE v_actor UUID:=auth.uid(); v_name TEXT;
BEGIN
  IF v_actor IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
  IF p_display_name IS NULL OR p_display_name<>pg_catalog.btrim(p_display_name)
    OR pg_catalog.char_length(p_display_name) NOT BETWEEN 2 AND 120
  THEN RAISE EXCEPTION 'Display name must contain 2 to 120 trimmed characters' USING ERRCODE='22023'; END IF;
  v_name:=p_display_name;
  INSERT INTO public.user_profiles(user_id,display_name,profile_complete)
    VALUES(v_actor,v_name,TRUE)
  ON CONFLICT(user_id) DO UPDATE SET display_name=EXCLUDED.display_name,
    profile_complete=TRUE,updated_at=pg_catalog.now();
  RETURN pg_catalog.jsonb_build_object('displayName',v_name,'complete',TRUE);
END;
$function$;

REVOKE ALL ON FUNCTION private.get_my_profile(),private.update_my_profile(TEXT)
  FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION private.get_my_profile(),private.update_my_profile(TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.get_my_profile()
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.get_my_profile(); $function$;
CREATE OR REPLACE FUNCTION public.update_my_profile(p_display_name TEXT)
RETURNS JSONB LANGUAGE SQL SECURITY INVOKER SET search_path=''
AS $function$ SELECT private.update_my_profile(p_display_name); $function$;

REVOKE ALL ON FUNCTION public.get_my_profile(),public.update_my_profile(TEXT) FROM PUBLIC,anon,service_role;
GRANT EXECUTE ON FUNCTION public.get_my_profile(),public.update_my_profile(TEXT) TO authenticated;
