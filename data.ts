var myHeaders = new Headers();
myHeaders.append("Authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzMzNDQ5MDAsImlhdCI6MTY0NzQyNDkwMCwic3ViIjoiZml4ZWQtaG9zdC1pZCJ9.566FJPbg1FRvsUNnCx2Gd8VQi_Ji5mf5y6MoTHj1tNE");

var requestOptions = {
    method: 'GET',
    headers: myHeaders,
    redirect: 'follow'
};

export const fetchData = async () => {
    return fetch("https://oetest.tech/live-sessions/api/v2/ar/online-sessions/get-session/fixed-live-session", requestOptions)
        .then(response => response.json())
        .then(result => result.data.attributes)
        .catch(error => console.log('error', error));
}

