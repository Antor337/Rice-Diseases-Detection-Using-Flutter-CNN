import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';


class home extends StatefulWidget
{
  @override
  State <home> createState()=>_home();
}
class _home extends State<home> {
  File? image;
  String imagepath = "";
  String get = "";
  String detect = "";
  String accuracy = "";
  double x = 0;
  String get_percent="";

  final TextEditingController take_name=TextEditingController();

  final _pic = new ImagePicker();

  Future<void> getcameraimage() async {
    final pickedfile = await _pic.pickImage(
        source: ImageSource.camera, imageQuality: 80);

    if (pickedfile != null) {
      image = File(pickedfile!.path);
      imagepath = image!.path;
      setState(() {

      });
    }
    else {
      final snackbar = SnackBar(content: Text("ছবি সংযুক্তকরণ ভুল হয়েছে",
        style: TextStyle(
            color: Colors.red, fontFamily: "SutonnyMJ", fontSize: 15),),
        backgroundColor: Colors.white,
        action: SnackBarAction(onPressed: () {},
            label: "বাতিল করুন"
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void savefile(String filename) async
  {
    final directory=Directory("/storage/emulated/0/Downloads");
    if(!directory.existsSync())
    {
      directory.create();
    }
    String med=take_medicine(detect);
    String sug=give_sug(detect);
    String diseases=getdiseases(detect);
    String cont = "$diseases \n$med \n$sug";
    final path="${directory.path}/$filename.txt"; // /storage/emulated/0/Downloads/healthy.txt
    final file=File(path);
    await file.writeAsString("$cont");
    OpenFilex.open("$path");

  }

  Future<void> getimage() async {
    final pickedfile = await _pic.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (pickedfile != null) {
      image = File(pickedfile!.path);
      imagepath = image!.path;
      setState(() {

      });
    }
    else {
      final snackbar = SnackBar(content: Text("ছবি সংযুক্তকরণ ভুল হয়েছে",
        style: TextStyle(
            color: Colors.red, fontFamily: "SutonnyMJ", fontSize: 15),),
        backgroundColor: Colors.white,
        action: SnackBarAction(onPressed: () {},
            label: "বাতিল করুন"
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> uploadimage() async {
    var dio = Dio();
    FormData data = FormData.fromMap(
        {"file": await MultipartFile.fromFile(imagepath)});
    var response = await dio.post("http://192.168.160.26:8000/predict", data: data);
    if (response.statusCode == 200) {
      setState(() {
        get = response.data.toString();
        accuracy = get.split(", ").last.split("]").first;
        if(accuracy=='1.0')
          {
            x = 1/100;
          }
        else
          {
            x = (int.parse(accuracy.substring(2, 6)) / 100);
          }
        //get_percent=convertNumber(x);
        if(x<=70.00)
          {
            detect = "";
          }
        else
          {
            detect = get.split(", ").first.split("[").last;
          }
        showresult(context);
      });
    }
    else {
      final snackBar = SnackBar(content: Text("সার্ভারে একটি সমস্যা হয়েছে",
        style: TextStyle(
            color: Colors.red, fontFamily: "SutonnyMJ", fontSize: 35),),
        backgroundColor: Colors.white,
        action: SnackBarAction(onPressed: () {}, label: "বাতিল করুন"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  String take_medicine(String diseases)
  {
    if (diseases == "Hispa")
      {
        return "প্রতিষেধক : অতিরিক্ত নিষিক্তকরণ এড়িয়ে চলুন এবং মিথাইল প্যারাথন ০.০৫% অথবা কুইনালফোস ০.০৫% স্প্রে করুন";
      }
    else if (diseases == "BrownSpot")
    {
      return "প্রতিষেধক : কার্বেন্ডাজিম (অটোস্টিন) অথবা কার্বোক্সিন + থিরাম (প্রোভ্যাক্স ২০০ ডব্লিউপি) প্রতি কেজি বীজে ২.৫ গ্রাম হারে মিশিয়ে শোধন করতে হবে";
    }
    else if (diseases == "LeafBlast")
    {
      return "প্রতিষেধক : ট্রাইসাইক্লাজল (ট্রুপার ৭৫ ডব্লিউপি) বা টেবুকোনাজল + ট্রাইফ্লক্সিস্ট্রবিন (নাটিভো৭৫ ডব্লিউপি) প্রতি লিটার পানিতে ১ গ্রাম হারে মিশিয়ে ১০-১৫ দিন পর পর ২-৩ বার স্প্রে করতে হবে";
    }
    else if (diseases == "Healthy")
    {
      return "ঔষুধের প্রয়োজন নেই";
    }
    else
    {
      return "";
    }
  }

  String give_sug(String diseases)
  {
    if (diseases == "Hispa")
    {
      return "রোগের কারণ : হিস্পা কিটের উপস্থিতির জন্য এ রোগ হয়ে থাকে";
    }
    else if (diseases == "BrownSpot")
    {
      return "রোগের কারণ : বাইপোলারিস ওরাইজি (Bipolaris oryzae) নামক ছত্রাক দ্বারা হয়ে থাকে";
    }
    else if (diseases == "LeafBlast")
    {
      return "রোগের কারণ : পাইরিকুলারিয়াগ্রিসিয়া (Pyricularia grisea) নামক ছত্রাক দ্বারা হয়ে থাকে";
    }
    else if (diseases == "Healthy")
    {
      return "এগিয়ে যান";
    }
    else
    {
      return "";
    }
  }
  
  String getdiseases(String diseases)
  {
    if (diseases == "Hispa")
    {
      return "রোগের নামঃ হিস্পা (Hispa)";
    }
    else if (diseases == "BrownSpot")
    {
      return "রোগের নামঃ ব্রাউনস্পট (BrownSpot)";
    }
    else if (diseases == "LeafBlast")
    {
      return "রোগের নামঃ লিফব্লাস্ট (LeafBlast)";
    }
    else if (diseases == "Healthy")
    {
      return "সুস্থ ধান (Healthy)";
    }
    else
      {
        return "সুনিশ্চিত কোনো তথ্য পাওয়া যায়নি";
      }
    
  }


  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height:double.infinity,
          color: Colors.black,
          child: RefreshIndicator(
            onRefresh: (){
              return Future.delayed(Duration(seconds: 2),(){
                setState(() {
                  image=null;
                  take_name.clear();
                  detect="";
                  accuracy="";
                });

              });
            },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height:35),
                Container(child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("  ধানের রোগ নির্ণায়ক",style: TextStyle(
                        color: Colors.white, fontFamily: "SutonnyMJ", fontSize: 25),),
                    SizedBox(width: 35),
                    IconButton(onPressed: (){showexit(context);}, icon: Icon(Icons.cancel,color: Colors.white),iconSize: 30,color: Colors.blue,)
                  ],
                )),


                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blue,width: 1))),),
                SizedBox(height: 55,),
                image !=null? Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 35,
                        width: 256,
                        color: Colors.black,
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(), //user/documents/name.jpg
                          child: Center(child:Text("${image!.path.split('/').last}",style: TextStyle(
                              color: Colors.white,fontFamily: "Times New Roman", fontSize: 20))),
                        ),
                      ),
                    ],
                  ),
                ):Text(""),
                SizedBox(height: 15),
                Container(
                  width:256,
                  height: 256,
                  decoration: BoxDecoration(border: Border.all(color: Colors.blue,width: 2)),
                  child: image == null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("[বি.দ্রঃ নির্ভুল ফলাফল পেতে আক্রান্ত অংশটিকে সাদা রং সদৃশ কোনো বস্তুর উপরে রাখুন]",textAlign: TextAlign.justify,style: TextStyle(
                          color: Colors.white, fontFamily: "SutonnyMJ", fontSize: 15),),
                      SizedBox(height: 20,),
                      IconButton(onPressed: (){showoption(context);}, icon: Icon(Icons.add_a_photo_rounded),color: Colors.white,iconSize: 55,),
                      SizedBox(height: 10,),
                      Text("ছবি সংযুক্ত করুন",style: TextStyle(
                          color: Colors.blue,fontFamily: "SutonnyMJ", fontSize: 15),)
                    ],
                  ):
                      Container(
                        child: Image.file(File(image!.path).absolute,fit: BoxFit.fill,width: 256,height: 256,),
                      )

                ),
                SizedBox(height:55),
                FloatingActionButton(onPressed: ()
                {
                  uploadimage();
                  },backgroundColor: Colors.blue,child: Icon(Icons.send_sharp,color: Colors.white,size: 28),),
                SizedBox(height:10),
                Text("ফলাফল দেখুন",style: TextStyle(
                    color: Colors.blue, fontFamily: "SutonnyMJ", fontSize: 18),)

              ],

            ),
           ),
          ),
        ),

      );

    }
    
    showoption(BuildContext context) {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 80,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Text("ক্যামেরা", style: TextStyle(color: Colors.black,
                        fontFamily: "Times New Roman", fontSize: 20)),
                    onTap: () {
                      getcameraimage();
                      Navigator.of(context).pop();
                      //build(context);
                    },
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(
                    child: Text("গ্যালারি", style: TextStyle(color: Colors.black,
                        fontFamily: "Times New Roman", fontSize: 20)),
                    onTap: () {
                      getimage();
                      Navigator.of(context).pop();
                      //build(context);
                      //showresult(context);
                    },
                  )
                ]
            ),
          ),);
      });
    }

      showresult(BuildContext context)
      {
        String try_again=getdiseases(detect);
        showModalBottomSheet(context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20)
              ),
            ),
            builder: (BuildContext){
          return SizedBox(
            height: 250,
            //color: Colors.blue,
            child:SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height:20),
                Text(getdiseases(detect),style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,
                    fontFamily: "Times New Roman",fontSize: 18),),
                SizedBox(height:20),
                GestureDetector(
                  child: try_again == "সুনিশ্চিত কোনো তথ্য পাওয়া যায়নি"? Text("আবার চেষ্টা করুন",style: TextStyle(decoration: TextDecoration.underline,color: Colors.black,
                      fontFamily: "Times New Roman",fontSize: 18)) : Text(""),
                  onTap: (){
                    setState(() {
                      image=null;
                      take_name.clear();
                      detect="";
                      accuracy="";
                      Navigator.of(context).pop();
                    });
                  },
                ),
                /*SizedBox(height:20),
                Text("সম্ভাবনাঃ $x %",textAlign: TextAlign.justify, style: TextStyle(color: Colors.black,
                    fontFamily: "Times New Roman",fontSize: 18),)*/
                SizedBox(height:20),
                Text(take_medicine(detect),textAlign: TextAlign.justify, style: TextStyle(color: Colors.black,
                    fontFamily: "Times New Roman",fontSize: 18),),
                SizedBox(height:20),
                Text(give_sug(detect),textAlign: TextAlign.justify, style: TextStyle(color: Colors.black,
                    fontFamily: "Times New Roman",fontSize: 18),),
                SizedBox(height:20),
                /*Container(
                  child: try_again != "সুনিশ্চিত কোনো তথ্য পাওয়া যায়নি"? IconButton(onPressed: () async{
                    getfile_name(context);

                  }, icon: Icon(Icons.file_download),color: Colors.black,iconSize: 35,): Text("")
                ),

                Text( try_again != "সুনিশ্চিত কোনো তথ্য পাওয়া যায়নি"? "ফোনে সেভ করুন" : "",style: TextStyle(color: Colors.black,
                    fontFamily: "Times New Roman",fontSize: 15),),*/
              ],
            ),
            )
          );
        });
      }
      getfile_name(BuildContext context)
      {
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            content: Container(
              height: 150,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:20),
                Text("ফাইলের নাম দিন?",style: TextStyle(color: Colors.black,
                fontFamily: "Times New Roman",fontSize: 18),),
                SizedBox(height: 5,),
                TextField(
                  controller: take_name,
                  style: TextStyle(fontFamily: "Times New Roman",color: Colors.black),
                  decoration: InputDecoration(
                      filled: true,
                      border: UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: ()
                        {
                          take_name.clear();
                        },
                      )
                  ),
                ),
                SizedBox(height: 5),
                Container(child: Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child: Text("ঠিক আছে",style: TextStyle(color: Colors.black,
                        fontFamily: "Times New Roman",fontSize: 18),),
                    onTap: (){
                      String x=take_name.text;
                      savefile(x);
                      Navigator.of(context).pop();
                    },
                  )
                ]),
                )
              ],
              ),
              )
            );
          }
        );
      }

  showexit(BuildContext context)
  {
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(title: Text("আপনি কি প্রস্থান করতে ইচ্ছুক?",style: TextStyle(color: Colors.blueAccent,
          fontFamily: "Times New Roman",fontSize: 20),),
        icon: Icon(Icons.android_outlined,size: 50,color: Colors.blueAccent),

        content: Container(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child:Text("হ্যা",style: TextStyle(color: Colors.blueAccent,
                      fontFamily: "Times New Roman",fontSize: 20)),
                  onTap: (){
                    SystemNavigator.pop();
                  },
                ),
                GestureDetector(
                  child:Text("না",style: TextStyle(color: Colors.blueAccent,
                      fontFamily: "Times New Roman",fontSize: 20)),
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                )
              ]
          ),
        ),);
    });
  }
}
