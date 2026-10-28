-- Private Tenant export storage read boundary. Every fixture is rolled back.
BEGIN;
DO $smoke$
DECLARE
  v_contact UUID := gen_random_uuid();
  v_other UUID := gen_random_uuid();
  v_tenant UUID := gen_random_uuid();
  v_export UUID := gen_random_uuid();
  v_path TEXT;
  v_visible BIGINT;
  v_private BOOLEAN;
BEGIN
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data
  ) VALUES
    (v_contact, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_contact::TEXT || '@tenant-export-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::JSONB, '{}'),
    (v_other, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     v_other::TEXT || '@tenant-export-smoke.invalid', '', now(), now(), now(),
     '{"provider":"email","providers":["email"]}'::JSONB, '{}');

  INSERT INTO public.tenants (id, slug, display_name, status, created_by)
  VALUES (v_tenant, 'export-' || LEFT(v_tenant::TEXT, 8), 'Export storage smoke', 'export_ready', v_contact);
  INSERT INTO public.memberships (tenant_id, user_id, status)
  VALUES (v_tenant, v_contact, 'active');

  v_path := v_tenant::TEXT || '/' || v_export::TEXT || '.json';
  INSERT INTO public.tenant_exports (
    id, tenant_id, requested_by, contact_user_id, status, artifact_path,
    artifact_sha256, artifact_bytes, manifest, generated_at, available_at,
    purge_after, idempotency_key
  ) VALUES (
    v_export, v_tenant, v_contact, v_contact, 'available', v_path,
    decode(repeat('ab', 32), 'hex'), 8, '{"datasets":[]}'::JSONB,
    now(), now(), now() + INTERVAL '90 days', gen_random_uuid()
  );
  INSERT INTO storage.objects (bucket_id, name, owner_id, metadata)
  VALUES ('tenant-exports', v_path, v_contact::TEXT,
          '{"size":"8","mimetype":"application/json"}'::JSONB);

  SELECT public_bucket.public = FALSE INTO v_private
  FROM storage.buckets AS public_bucket WHERE public_bucket.id = 'tenant-exports';
  IF v_private IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'Tenant export bucket is missing or public';
  END IF;

  PERFORM set_config('request.jwt.claim.sub', v_contact::TEXT, TRUE);
  EXECUTE 'SET LOCAL ROLE authenticated';
  SELECT count(*) INTO v_visible FROM storage.objects
  WHERE bucket_id = 'tenant-exports' AND name = v_path;
  IF v_visible <> 1 THEN RAISE EXCEPTION 'Authorized export contact cannot read the ready artifact'; END IF;

  BEGIN
    PERFORM 1 FROM public.tenant_exports WHERE id = v_export;
    RAISE EXCEPTION 'Authenticated actor can directly read export metadata';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    INSERT INTO storage.objects (bucket_id, name, owner_id, metadata)
    VALUES ('tenant-exports', v_tenant::TEXT || '/' || gen_random_uuid()::TEXT || '.json',
            v_contact::TEXT, '{"size":"1","mimetype":"application/json"}'::JSONB);
    RAISE EXCEPTION 'Authenticated actor can upload an unverified export artifact';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;

  PERFORM set_config('request.jwt.claim.sub', v_other::TEXT, TRUE);
  SELECT count(*) INTO v_visible FROM storage.objects
  WHERE bucket_id = 'tenant-exports' AND name = v_path;
  IF v_visible <> 0 THEN RAISE EXCEPTION 'Unrelated actor can read a Tenant export'; END IF;

  PERFORM set_config('request.jwt.claim.sub', v_contact::TEXT, TRUE);
  EXECUTE 'RESET ROLE';
  UPDATE public.memberships SET status = 'revoked', revoked_at = now()
  WHERE tenant_id = v_tenant AND user_id = v_contact;
  EXECUTE 'SET LOCAL ROLE authenticated';
  SELECT count(*) INTO v_visible FROM storage.objects
  WHERE bucket_id = 'tenant-exports' AND name = v_path;
  IF v_visible <> 0 THEN RAISE EXCEPTION 'Revoked export contact can still read the artifact'; END IF;
END;
$smoke$;
ROLLBACK;
