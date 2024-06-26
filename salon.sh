#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  echo -e "\n~~~~~ Welcome to our Salon ~~~~~\n"
  echo "Here is the list of services we offer:"
  SERVICE_LIST=$($PSQL "select service_id, name from services")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # get service_id from customer
  read SERVICE_ID_SELECTED
  SALON_SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  
  # if salon service not available
  if [[ -z $SALON_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # if service available, get details from customer
    echo "Your phone number"
    read CUSTOMER_PHONE
    
    # check if customer name is already present in DB
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    
    # if new customer
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo "Your beautiful name"
      read CUSTOMER_NAME
      # add customer to DB
      INSERT_CUSTOMER=$($PSQL "insert into customers(phone,name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi

    # schedule time for appointment
    echo "When shall we book your appointment, $(echo $CUSTOMER_NAME | sed 's/^ *//g')?"
    read SERVICE_TIME

    # get the customer id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    
    # remove white spaces in customer id
    CUSTOMER_ID=$(echo $CUSTOMER_ID | sed 's/^ *| *$//g')

    # add appointment
    INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "I have put you down for a $SALON_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

  fi
}

MAIN_MENU
