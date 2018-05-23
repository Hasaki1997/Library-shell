#!/bin/bash

# 图书信息储存在 library 文件中,每行为一个记录,包含了书籍的六种信息,分别为:
# 书名
# 作者
# 种类 系统书:system 参考书:reference 教科书:textbook
# 状态 借出:out 未被借出:in
# 借阅者姓名 当状态为 in 时,借阅者姓名为空
# 借出日期
# 每条记录中各个字段之间的间隔符为 :

# 程序结构
#      +> 0 EXIT    :退出程序
#      |
#      |
#      |          +> 0 ADD     :增加一本书
#      |          |
#      |          +> 1 DELETE  :删除一本书
# menu +> 1 EDIT+->
#      |          +> 2 DISPLAY :显示指定的书
#      |          |
#      |          +> 3 UPDATE  :借出/还回书籍时更新书籍状态
#      |
#      |
#      +> 2 REPORTS :按一定格式显示所有书籍

# edit 菜单,包括 add , delete , display , update 四个功能模块
edit(){
    while true
    do
        clear
        echo -e "Linux Library - \033[1m EDIT MENU \033[0m
        0: \033[1m RETURN \033[0m to the main menu
        1: \033[1m ADD \033[0m
        2: \033[1m UPDATE STATUS \033[0m
        3: \033[1m DISPLAY \033[0m
        4: \033[1m DELETE \033[0m
Enter your choice > \c"
        read char_edit
        case ${char_edit} in
            0) clear
                menu
                ;;
            1) add
                ;;
            2) update
                ;;
            3) display
                ;;
            4) delete
                ;;
            *) echo "Wrong input. Try again"
                ;;
        esac
    done

}

# add 增加一条记录
add(){
    clear
    read -p "title:     " title
    read -p "author:    " author
    read -p "category:  " categort
    echo "${title}:${author}:${categort}:"in"::"$(date +%x)"" >> ULIB_FILE
    read -p "Any more to add? (Y)es or (N)o > " next
    if [[ $next == "Y" || $next == "Yes" ]]
    then
        add
    fi
    clear
}


# update 当借出一本书或还回一本书时,更改 ULIB_FILE 库文件中指定记录的状态
update(){
    display
    if [[ "${arr[3]}" == "in" ]]
    then
        read -p "enter name >" name
        new_date=$(date +%x)
        echo "
            title: ${arr[0]}
            author:${arr[1]}
            category:${arr[2]}
            status:"out"
            checked out by:${name}
            date:${new_date}
     "
        grep -v "${tmp}" ULIB_FILE > temp
        mv temp ULIB_FILE
        echo "${arr[0]}:${arr[1]}:${arr[2]}:"out":"${name}":"${new_date}"" >> ULIB_FILE
    else
        new_date=$(date +%x)
        grep -v "${tmp}" ULIB_FILE > temp
        mv temp ULIB_FILE
        echo "${arr[0]}:${arr[1]}:${arr[2]}:"in":"${name}":"${new_date}"" >> ULIB_FILE
        echo "
            title:  ${arr[0]}
            author: ${arr[1]}
            category: ${arr[2]}
            status: in
            checked out by: ${arr[4]}
            date: ${arr[5]}

            New status: in
            "
    fi
    read -p "Any more to update ? (Y)es or (N)o  >" update_next
    if [[ $update_next == "Y" || $update_next == "Yes" ]]
    then
        update
    fi

}

# display 把 ULIB_FILE 库文件中指定记录的内容显示出来
display(){
    clear
        read -p "Enter the title >" title
        num=$(grep -c "${title}:" ULIB_FILE)
        if [ $num == 0 ]
        then
            read -p "connot find this book ,any more to look for? (Y)es or (N)o > " find_next
            if [[ $find_next == "Y" || $find_next == "Yes" ]]
            then
                display
            else
                edit
            fi
        else
            tmp=$(grep "${title}:" ULIB_FILE)
            OLD_IFS="$IFS"
            IFS=":"
            arr=($tmp)
            IFS="$OLD_IFS"
            echo "
            title: ${arr[0]}
            author:${arr[1]}
            category:${arr[2]}
            status:${arr[3]}
            "
            read -p "Enter the return car to continue! "
        fi
}




# delete 删除一条记录

delete(){
    clear
    read -p "Enter the title >" title
    num=$(grep -c "${title}:" ULIB_FILE)
    if [ $num == 0 ]
    then
        echo "connot find this book,return to EDIT MENU after 3 seconds "
        sleep 3s
    else
        tmp=$(grep "${title}:" ULIB_FILE)
        OLD_IFS="$IFS"
        IFS=":"
        arr=($tmp)
        IFS="$OLD_IFS"
        echo "
        title: ${arr[0]}
        author:${arr[1]}
        category:${arr[2]}
        status:${arr[3]}
        "
        read -p "Delete this book?  (Y)es or (N)o > " delete_ok
        if [[ $delete_ok == "Y" || $delete_ok == "Yes" ]]
        then
            grep -v "${tmp}" ULIB_FILE > temp
            mv temp ULIB_FILE
            read -p "have deleted!
Any more to delete ? (Y)es or (N)o > " delete_next
            if [[ $delete_next == "Y" || $delete_next == "Yes" ]]
            then
                delete
            fi
        fi

    fi
}

mysort(){
    > reports_file
    # 将原文件排序,并重定向到原文件 -n 以数值来排序 -k 按第1列的值排序 -t 定义分割符 -o 重定向
    sort -k ${1} -t : ULIB_FILE -o ULIB_FILE
    while read LINE
    do
        OLD_IFS="$IFS"
        IFS=":"
        arr=($LINE)
        IFS="$OLD_IFS"
        echo "
        title: ${arr[0]}
        author:${arr[1]}
        category:${arr[2]}
        status:${arr[3]}
        " >> reports_file
    done < "ULIB_FILE"
    more reports_file
}

#   以一定格式显示所有记录
reports(){
    clear
    while true
    do
        echo -e "Linux Library - \033[1m REPORTS MENU \033[0m
            0: \033[1m RETURN \033[0m
            1: sort by \033[1m TITLE \033[0m
            2: sort by \033[1m AUTHOR \033[0m
            3: sort by \033[1m CATEGORY \033[0m
Enter your choice > \c"
        read char_menu
        case ${char_menu} in
            0) clear
                break
                ;;
            1) mysort 1
                ;;
            2) mysort 2
                ;;
            3) mysort 3
                ;;
            *) echo "Wrong input. Try again >\c"
                    ;;
        esac
    done
}

# 主菜单
menu(){
    clear
    while true
    do
        echo -e "Linux Library - \033[1m MAIN MENU \033[0m
            0: \033[1m EXIT \033[0m this program
            1: \033[1m EDIT \033[0m Menu
            2: \033[1m REPORTS \033[0m Menu
Enter your choice > \c"
        read char_menu
        case ${char_menu} in
            0) exit
                ;;
            1) clear
                edit
                ;;
            2) reports
                ;;
            *) echo "Wrong input. Try again >\c"
                    ;;
        esac
    done
}
# 运行程序
menu
