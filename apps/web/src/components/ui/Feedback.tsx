type FeedbackProps = { children: string; tone?: "info" | "success" | "error" };

export function Feedback({ children, tone = "info" }: FeedbackProps) {
  return <p className={`ui-feedback ui-feedback-${tone}`} role={tone === "error" ? "alert" : "status"}>{children}</p>;
}
