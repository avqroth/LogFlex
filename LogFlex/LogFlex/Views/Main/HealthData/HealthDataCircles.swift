import SwiftUI

struct HealthDataRectangle: View {
    let title: String
    let value: String
    let systemName: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: systemName)
                .foregroundColor(.main)
                .font(.system(size: 25))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(height: 70)
    }
}


struct HealthDataRectangle_Previews: PreviewProvider {
    static var previews: some View {
        HealthDataRectangle(
            title: "Steps",
            value: "10,456",
            systemName: "figure.walk"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

struct HealthProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        HealthProgressCircle(healthKitManager: HealthKitManager())
            .previewLayout(.sizeThatFits)
    }
}
