// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket, Presence } from "phoenix";

let socket = null;
let chatInput = document.querySelector("#chat-input");

if (chatInput) {
  // And connect to the path in "lib/slink_web/endpoint.ex". We pass the
  // token for authentication.
  //
  // Read the [`Using Token Authentication`](https://hexdocs.pm/phoenix/channels.html#using-token-authentication)
  // section to see how the token should be used.

  const csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");

  socket = new Socket("/ws/chat", {
    debug: true,
    params: { _csrf_token: csrfToken },
  });

  // Now that you are connected, you can join channels with a topic.
  // Let's assume you have a channel with a topic named `room` and the
  // subtopic is its id - in this case 42:
  let channel = socket.channel("room:lobby", {
    msg: "mock channel msg",
  });

  let presence = new Presence(channel);

  function renderOnlineUsers(presence) {
    let response = "";

    presence.list((id, { metas: [first, ...rest] }) => {
      let count = rest.length + 1;
      response += `${id} (count: ${count})</br>`;
    });

    document.querySelector("#presence-info").innerHTML = response;
  }

  socket.connect();

  presence.onSync(() => renderOnlineUsers(presence));

  // console.log(`connected socket: ${JSON.stringify(socket, null, 2)}`);
  let messagesContainer = document.querySelector("#messages");

  chatInput.addEventListener("keypress", (event) => {
    if (event.key === "Enter") {
      channel.push("new_msg", { body: chatInput.value });
      chatInput.value = "";
    }
  });

  channel.on("new_msg", (payload) => {
    let messageItem = document.createElement("p");
    messageItem.innerText = `[${Date()}] ${JSON.stringify(payload, null, 2)}`;
    messageItem.classList.add("mb-2");
    messagesContainer.prepend(messageItem);
  });

  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully in chat_socket.js", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  let btn = document.querySelector("#set-socket");
  btn.addEventListener("click", (event) => {
    channel.push("set-socket", { something: "some value" });
  });
}

export default socket;
