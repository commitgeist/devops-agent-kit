const API_CONTATO = import.meta.env.VITE_API_CONTATO;
document.querySelector('#app').innerHTML = `<h1>Bem-vindo</h1><a href="${API_CONTATO}">Contato</a>`;
