window.formbutton =
  window.formbutton ||
  function() {
    (formbutton.q = formbutton.q || []).push(arguments);
  };
formbutton("create", {
  action: "https://formspree.io/YOUR_FORM_ID",
  title: "SUGGEST FILM",
  fields: [
    {
      type: "text",
      label: "Title:",
      name: "title",
      required: true,
    },
    {
      type: "text",
      label: "Director:",
      name: "director",
      required: true,
    },
    {
      type: "text",
      label: "Subtitles",
      name: "subtitles",
    },
    {
      type: "textarea",
      label: "Message:",
      name: "message",
    },
    {
      type: "email",
      label: "Email:",
      name: "email",
    },
    {
      type: "checkbox",
      label: "Notify me when my film is uploaded",
      name: "_optin",
    },
    { type: "submit",
      value: "Send",
      style: {
        input: {
          background: "#333",
          color: "#eaeaea",
          padding: "5px",
        }
      }
    }
  ],
  styles: {
    fontFamily:  "Press Start 2P",
    modal: {
      border: "1px solid #6D6875",
      boxShadow: "6px 6px 0 #333333",
      borderRadius: "0",
    },
    title: {
      padding: "24px 24px 0px 24px",
      background: "#eaeaea",
      color: "#2e2a37",
      fontFamily: "Press Start 2P",
      fontSize: "1.5em",
    },
    body: {
        padding: "16px 24px 24px",
      background: "#eaeaea"
    },
    field: {
      display: "flex",
    },
    submitField: {
      justifyContent: "flex-end",
    },
    label: {
      width: "40%",
      fontFamily: "Press Start 2P",
      fontWeight: "bold"
    },
    checkboxLabel: {
      width: "auto",
    },
    input: {
      borderRight: "1px solid rgba(0,0,0,0.1)",
      borderBottom: "1px solid rgba(0,0,0,0.1)",
      borderRadius: "0px",
      background: "#eaeaea"
    },
    button: {
      background: "#eaeaea",
      fill: "#333333",
      border: "1px solid #6D6875",
      boxShadow: "3px 3px 0px #333333"
    },
    closeButton: {
      textShadow: "0 0 0 #2e2a37",
    }
  },
  initiallyVisible: false
});