const API_AUTH = 'http://localhost:3001';
const API_MANAGER = 'http://localhost:3003';

let isLogin = true;

// Seletores
const authForm = document.getElementById('auth-form');
const taskForm = document.getElementById('task-form');
const authSection = document.getElementById('auth-section');
const mainSection = document.getElementById('main-section');
const tasksList = document.getElementById('tasks-list');

document.addEventListener('DOMContentLoaded', () => {
    checkInitialSession();
});

async function checkInitialSession() {
    try {
        const response = await fetch(`${API_AUTH}/validate_session`, {
            method: 'GET',
            credentials: 'include' // Obrigatório para enviar o cookie httponly
        });

        if (response.ok) {
            console.log("Sessão ativa encontrada.");
            showDashboard(); // Esconde login, mostra painel
            loadTasks();    // Carrega a lista de tarefas
        } else {
            showLoginPage(); // Mostra tela de login
        }
    } catch (error) {
        showLoginPage();
    }
}

// Alternar entre Login e Signup
document.getElementById('toggle-auth').addEventListener('click', (e) => {
    isLogin = !isLogin;
    document.getElementById('auth-title').innerText = isLogin ? 'Entrar' : 'Cadastrar';
    document.getElementById('auth-btn').innerText = isLogin ? 'Acessar' : 'Criar Conta';
    e.target.innerText = isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Logar';
});

// Login ou Signup
authForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const endpoint = isLogin ? '/login' : '/signup';

    try {
        const res = await fetch(`${API_AUTH}${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password }),
            // Importante para receber e guardar o cookie HttpOnly
            credentials: 'include'
        });

        if (res.ok) {
            showDashboard();
        } else {
            alert('Erro na autenticação!');
        }
    } catch (err) { console.error(err); }
});

// Criar Task
taskForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const title = document.getElementById('task-title').value;
    const url = document.getElementById('task-url').value;

    await fetch(`${API_MANAGER}/tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ task: { title, url } }),
        credentials: 'include' // Envia o cookie automaticamente
    });
    
    taskForm.reset();
    loadTasks();
});

async function loadTasks() {
    const res = await fetch(`${API_MANAGER}/tasks`, { credentials: 'include' });
    if (res.ok) {
        const tasks = await res.json();
        tasksList.innerHTML = tasks.map(t => `
            <tr>
                <td>${t.title}</td>
                <td><span class="status-${t.status}">${t.status}</span></td>
                <td>${JSON.stringify(t.result || {})}</td>
                <td>${new Date(t.created_at).toLocaleString()}</td>
            </tr>
        `).join('');
    }
}

function showDashboard() {
    authSection.classList.add('hidden');
    mainSection.classList.remove('hidden');
    loadTasks();
}

async function logout() {
    try {
        await fetch(`${API_AUTH}/logout`, {
            method: 'DELETE',
            credentials: 'include'
        });
        
        // Limpa o estado local e volta pro login
        window.location.reload(); // Forma mais limpa de resetar o estado do JS
    } catch (error) {
        console.error("Erro ao deslogar:", error);
    }
}

document.getElementById('logout-btn').addEventListener('click', logout);

function showLoginPage() {
    authSection.classList.remove('hidden');
    mainSection.classList.add('hidden');
}