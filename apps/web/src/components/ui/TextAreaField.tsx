import type { ReactNode, TextareaHTMLAttributes } from "react";

type TextAreaFieldProps = Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, "id"> & {
  id: string;
  label: string;
  hint?: ReactNode;
};

export function TextAreaField({ id, label, hint, className = "", ...props }: TextAreaFieldProps) {
  const hintId = hint ? `${id}-hint` : undefined;
  return <div className="ui-field">
    <label htmlFor={id}>{label}</label>
    <textarea id={id} className={`ui-text-area-field ${className}`.trim()} aria-describedby={hintId} {...props} />
    {hint && <small id={hintId} className="ui-field-hint">{hint}</small>}
  </div>;
}
