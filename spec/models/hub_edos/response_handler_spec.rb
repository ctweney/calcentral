describe HubEdos::ResponseHandler do

  class Worker
    include HubEdos::ResponseHandler

    def fetch_first_postal_code(parsed_response)
      students = get_students(parsed_response)
      if students.any?
        {
          postalCode: students[0]['addresses'][0]['postalCode']
        }
      else
        {}
      end
    end
  end

  subject { Worker.new.fetch_first_postal_code parsed_response }

  context 'successful fetch' do
    let(:parsed_response) {
      {
        'studentResponse' => {
          'students' => {
            'students' => [
              {
                'addresses' => [
                  {
                    'postalCode' => '454554',
                    'countryCode' => 'USA'
                  }
                ]
              }
            ]
          }
        }
      }
    }
    it 'should find postal code' do
      expect(subject).to eq({ postalCode: '454554' })
    end
  end

  context 'unsuccessful fetch' do
    context 'nil response' do
      let(:parsed_response) { nil }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end

    context 'empty response' do
      let(:parsed_response) { {} }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end

    context 'incomplete response' do
      let(:parsed_response) {
        {
          'studentResponse' => {
            'students' => {
              'notTheDroids' => 'you are looking for!'
            }
          }
        }
      }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end

    context 'students element does not respond_to? :each' do
      let(:parsed_response) {
        {
          'studentResponse' => {
            'students' => {
              'students' => 'this string is supposed to be an array'
            }
          }
        }
      }
      it 'should return nothing' do
        expect(subject).to be_empty
      end
    end
  end
end
