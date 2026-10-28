CREATE OR REPLACE FUNCTION private.audit_payload_is_safe(p_value JSONB)
RETURNS BOOLEAN
LANGUAGE PLPGSQL
IMMUTABLE
SET search_path = ''
AS $function$
DECLARE
  v_text TEXT;
  v_safe BOOLEAN;
BEGIN
  IF p_value IS NULL OR pg_catalog.jsonb_typeof(p_value) = 'null' THEN
    RETURN TRUE;
  ELSIF pg_catalog.jsonb_typeof(p_value) = 'object' THEN
    SELECT COALESCE(pg_catalog.bool_and(
      key !~* '(password|passwd|token|secret|cookie|authorization|credential|api[_-]?key|private[_-]?key)'
      AND private.audit_payload_is_safe(value)
    ), TRUE) INTO v_safe
    FROM pg_catalog.jsonb_each(p_value);
    RETURN v_safe;
  ELSIF pg_catalog.jsonb_typeof(p_value) = 'array' THEN
    SELECT COALESCE(pg_catalog.bool_and(private.audit_payload_is_safe(value)), TRUE)
      INTO v_safe FROM pg_catalog.jsonb_array_elements(p_value);
    RETURN v_safe;
  ELSIF pg_catalog.jsonb_typeof(p_value) = 'string' THEN
    v_text := p_value #>> '{}';
    RETURN v_text !~* '(password|passwd|token|secret|cookie|authorization|credential|api[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:],;]+'
      AND v_text !~* '(^|[[:space:]])Bearer[[:space:]]+[[:alnum:]._~-]{20,}'
      AND v_text !~ '[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}';
  END IF;
  RETURN TRUE;
END;
$function$;

REVOKE ALL ON FUNCTION private.audit_payload_is_safe(JSONB)
  FROM PUBLIC, anon, authenticated, service_role;

ALTER TABLE public.audit_events
  ADD CONSTRAINT audit_events_redacted_payload_check CHECK (
    private.audit_payload_is_safe(to_jsonb(reason))
    AND private.audit_payload_is_safe(before_redacted)
    AND private.audit_payload_is_safe(after_redacted)
  );
