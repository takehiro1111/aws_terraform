from locust import HttpUser, TaskSet, task, constant_pacing

class UserBehavior(TaskSet):
    
    @task(1)
    def search(self):
        self.client.get("/")

class WebsiteUser(HttpUser):
    tasks = {UserBehavior: 1}
    wait_time = constant_pacing(1)
    # 負荷をかけたいドメインを指定
    host = "https://cdn.takehiro1111.com"
