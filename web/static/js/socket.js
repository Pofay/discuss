import { Socket } from 'phoenix';

let socket = new Socket('/socket', { params: { token: window.userToken } });
let comments = [];

socket.connect();

const createSocket = (topicId) => {
  let channel = socket.channel(`comments:${topicId}`, {});
  channel
    .join()
    .receive('ok', (resp) => {
      comments.push(...resp.comments);
      renderComments(comments);
    })
    .receive('error', (resp) => {
      console.log('Unable to join', resp);
    });

  channel.on('comments:added', (resp) => {
    comments.push(resp.comment);
    renderComments(comments);
  });

  document.querySelector('button').addEventListener('click', (e) => {
    e.preventDefault();
    const content = document.querySelector('textarea').value;

    channel.push('comments:add', { content: content });
  });
};

function renderComments(comments) {
  const renderedComments = comments.map((comment) => {
    return `
      <li class="collection-item">
        ${comment.content}
      </li>
    `
  });

  document.querySelector('.collection').innerHTML = renderedComments.join('');
}

window.createSocket = createSocket;
