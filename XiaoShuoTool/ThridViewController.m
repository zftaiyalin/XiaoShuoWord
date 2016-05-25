//
//  ThridViewController.m
//  XiaoShuoTool
//
//  Created by AnFeng on 16/5/25.
//  Copyright © 2016年 TheLastCode. All rights reserved.
//

#import "ThridViewController.h"
#import "WordClassModel.h"
#import "FourViewController.h"

@interface ThridViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tv;
}

@end

@implementation ThridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.title = @"";
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    
    _tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tv.dataSource = self;
    _tv.delegate = self;
    _tv.allowsSelection=YES;
    _tv.showsHorizontalScrollIndicator = NO;
    _tv.showsVerticalScrollIndicator = NO;
    _tv.backgroundColor = [UIColor clearColor];
    [_tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"optionCell"];
    [self.view addSubview:_tv];
}
-(void)edit{
    FourViewController *vc=[FourViewController new];
    vc.mainData=[WordClassModel new];
    [_mainData.wordArray addObject:vc.mainData];
    [self.navigationController pushViewController:vc animated:YES];
//    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
//        NSLog(@"animation complete");
//    };
//    
//    
//    MMAlertView *alertView = [[MMAlertView alloc] initWithInputTitle:@"添加类型标签" detail:nil placeholder:@"类型标签" handler:^(NSString *text) {
//        NSLog(@"input:%@",text);
//        
//        if(text.length>0){
//            [self addStatusTagsInfo:text];
//        }
//    }];
//    alertView.maxInputLength=10;
//    alertView.attachedView = self.view;
//    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
//    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleExtraLight;
//    [alertView showWithBlock:completeBlock];
}

-(void)viewWillAppear:(BOOL)animated{
    [_tv reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setMainData:(WordModel *)mainData{
    _mainData=mainData;
    self.title=_mainData.title;
}

-(void)addStatusTagsInfo:(NSString *)text{
//    MainModel *da=  [MainModel new];
//    da.string=text;
//    [_mainData.array addObject:da];
//    [[ToolManager sharedInstance]saveXiaoShuo];
//    [_tv reloadData];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Table view data source


- (void)viewDidLayoutSubviews
{
    if ([_tv respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tv setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tv respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tv setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}
//cell即将展示的时候调用
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mainData.wordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell" forIndexPath:indexPath];
    WordClassModel *model=[_mainData.wordArray objectAtIndex:indexPath.row];
    cell.textLabel.text=model.content;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WordClassModel *model=[_mainData.wordArray objectAtIndex:indexPath.row];
    FourViewController *vc=[FourViewController new];
    vc.mainData=model;
    [self.navigationController pushViewController:vc animated:YES];
}


//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    //删除cell
//    //    if (editingStyle ==UITableViewCellEditingStyleDelete)
//    //    {
//    //        illnessModel *data= [_lnessDiagnoseModel.data objectAtIndex:indexPath.row];
//    //
//    //        deleteIllnessDiagnoseApi *api = [[deleteIllnessDiagnoseApi alloc] initWithContentId:[NSNumber numberWithInteger:data.id]];
//    //
//    //        [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
//    //            [_lnessDiagnoseModel.data removeObjectAtIndex:indexPath.row];
//    //            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    //        } failure:^(YTKBaseRequest *request) {
//    //            NSLog(@"failed");
//    //        }];
//    //        //        [self.friendListremoveObjectAtIndex:indexPath.row];  //删除数据源记录
//    //
//    //    }
//}
@end
