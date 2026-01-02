all:
	@mkdir -p /home/${USER}/data/mariadb
	@mkdir -p /home/${USER}/data/wordpress
	@docker-compose -f srcs/docker-compose.yml up --build -d

down:
	@docker-compose -f srcs/docker-compose.yml down

clean:
	@docker-compose -f srcs/docker-compose.yml down --rmi all --volumes

fclean: clean
	@sudo rm -rf /home/${USER}/data

re: fclean all

.PHONY: all down clean fclean re