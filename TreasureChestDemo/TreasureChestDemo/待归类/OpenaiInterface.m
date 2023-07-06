////
////  OpenaiInterface.m
////  TreasureChest
////
////  Created by imvt on 2023/2/8.
////  Copyright © 2023 xiao ming. All rights reserved.
////
//
//#import "OpenaiInterface.h"
//
//
//@interface OpenaiInterface()
//@end
//
//@implementation OpenaiInterface
//
///**
// OC 调用 Python (基于 c/c++ 调用 Python)
// 
// @param module python 模块名称
// @param funcKey 函数名称
// @param args 函数参数
// @return 返回值
// */
//- (NSString *)pyCallWithModule:(char * _Nonnull)module funcKey:(char * _Nonnull)funcKey Args:(char * _Nonnull)args {
//    
//    // 初始化 python 解释器
//    Py_Initialize();//提示报错：Implicit declaration of function 'Py_Initialize' is invalid in C99
//    if (!Py_IsInitialized()) {
//        return @"error: 初始化环境失败";
//    }
//    
//    // 新增 python 路径这里的新增路径是 xcode 内 python 文件的路径, 这一步很关键， 不设置 python 环境将无法检测到 xcode 工程下的 python 模块
//    PySys_SetPath((char *)[[NSString stringWithFormat:@"%s:%@", Py_GetPath(), [[NSBundle mainBundle] resourcePath]] UTF8String]);
//    
//    // 初始化参数
//    PyObject *pModule = NULL, *pFunc = NULL, *pDict = NULL, *pValue = NULL, *pResult = NULL;
//
//    pModule = PyImport_ImportModule(module);
//    if (!pModule) {
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return [NSString stringWithFormat:@"error: %s 模块找不到", module];
//    }
//    
//    // 使用PyObject* pDict来存储导入模块中的方法字典
//    pDict = PyModule_GetDict(pModule);
//    if(!pDict) {
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return [NSString stringWithFormat:@"error: %s 模块中未定义方法", module];
//    }
//    
//    // 获取模块中的函数
//    pFunc = PyDict_GetItemString(pDict, funcKey);
//    if(!pFunc || !PyCallable_Check(pFunc)) {
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return @"error: 方法获取失败";
//    }
//    
//    // 函数参数
//    pValue = Py_BuildValue("(z)", args);
//    if(!pValue) {
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return @"error: 参数转换失败";
//    }
//    // 调用函数获取 return 值
//    pResult = PyObject_CallObject(pFunc, pValue);
//    if (!pResult) {
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return @"error: return 值出错";
//    }
//    
//    //结果处理
//    if (PyString_Check(pResult)) {
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return [NSString stringWithUTF8String: PyString_AsString(pResult)];
//    } else if (PyInt_Check(pResult)) {
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return [NSString stringWithFormat:@"%ld", PyInt_AsLong(pResult)];
//    } else {
//        NSDictionary *paramsDic = @{@"success": @"yes", @"msg": @"Python 函数 return 值获取失败"};
//        NSError *dataError = nil;
//        NSData *data = [NSJSONSerialization dataWithJSONObject:paramsDic options:NSJSONWritingPrettyPrinted error:&dataError];
//        NSString *paramsStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        finalize(pModule ,pFunc ,pDict ,pValue, pResult);
//        return paramsStr;
//    }
//    
//}
//
//void finalize(PyObject *pModule, PyObject *pFunc, PyObject *pDict, PyObject *pValue, PyObject *pResult) {
//    PyErr_Print();
//    //释放对象
//    if (Py_IsInitialized()) {
//        Py_Finalize();
//    }
//}
//
//@end
