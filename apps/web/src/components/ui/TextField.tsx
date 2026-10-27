import type { InputHTMLAttributes } from "react";

type TextFieldProps = Omit<InputHTMLAttributes<HTMLInputElement>, "id"> & {
  id: string;
  label: string;
  hint?: string;
};

export function TextField({ id, label, hint, className = "", ...props }: TextFieldProps) {
  const hintId = hint ? `${id}-hint` : undefined;
  return <div className="ui-field">
    <label htmlFor={id}>{label}</label>
    <input id={id} className={`ui-text-field ${className}`.trim()} aria-describedby={hintId} {...props} />
    {hint && <small id={hintId} className="ui-field-hint">{hint}</small>}
  </div>;
}
