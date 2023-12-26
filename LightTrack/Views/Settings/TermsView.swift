// TermsView.swift

import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Text("1. はじめに\n本利用規約（以下「本規約」といいます）は、Light Track（以下「本アプリ」といいます）の提供条件および運営者（以下「運営者」といいます）と本アプリのユーザー（以下「ユーザー」といいます）との間の権利義務関係を定めるものです。ユーザーは、本アプリを利用する前に、本規約をよく読み、その内容を理解し、同意した上で本アプリを利用してください。")
                        .padding(.bottom)
                    Text("2. サービスの利用\nユーザーは、本アプリを通じて、体重、体脂肪率、BMIの管理を行うことができます。登録されたデータはアプリ内にのみ保存され、外部と共有されることはありません。")
                        .padding(.bottom)
                    Text("3. 禁止事項\nユーザーは、本アプリを通じて取得した情報を商用目的で使用することや、本アプリの著作権を侵害する行為を行ってはなりません。また、本アプリを不正に利用する行為も禁止されています。")
                        .padding(.bottom)
                }
                Group {
                    Text("4. 広告について\n本アプリは、AdMob広告を表示することにより収益を得ています。広告の内容については、広告提供者の責任において提供されるものであり、運営者はその内容について一切の責任を負いません。")
                        .padding(.bottom)
                    Text("5. 免責事項\n運営者は、本アプリの完全性、正確性、信頼性について保証しません。本アプリの利用により生じたいかなる損害に対しても、運営者は責任を負わないものとします。ユーザーは自己の責任において本アプリを利用するものとします。")
                        .padding(.bottom)
                    Text("6. 規約の変更\n運営者は、ユーザーに事前通知することなく、本規約を変更することがあります。変更後の規約に同意できない場合、ユーザーは直ちに本アプリの利用を中止し、アプリをアンインストールする権利があります。")
                        .padding(.bottom)
                }
                Group {
                    Text("7. 連絡先\n本アプリに関するお問い合わせは、運営者の公式メールアドレスまでお願いします。詳細はアプリ内の「お問い合わせ」セクションをご参照ください。")
                }
                Spacer()
                    .frame(height: 50)
            }
            .padding()
        }
        .background(Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255))
        .foregroundColor(.white)
        .navigationTitle("利用規約")
    }
}
