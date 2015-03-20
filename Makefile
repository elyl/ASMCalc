NAME=	calc
SRC=	calc.s
OBJ=	$(SRC:.s=.o)
CC=	gcc
CFLAGS=	-g
RM=	@rm -fv

$(NAME):	$(OBJ)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJ)

clean:
	$(RM) $(OBJ)

fclean:
	$(RM) $(NAME)

re: clean, fclean, $(NAME)