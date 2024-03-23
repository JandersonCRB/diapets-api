module Entities
  class InsulinApplicationsFiltersEntity < Grape::Entity
    expose :min_date, documentation: { type: 'DateTime', desc: 'The minimum date of the insulin applications', required: false }
    expose :max_date, documentation: { type: 'DateTime', desc: 'The maximum date of the insulin applications', required: false }
    expose :min_units, documentation: { type: 'Integer', desc: 'The minimum insulin units of the insulin applications', required: false }
    expose :max_units, documentation: { type: 'Integer', desc: 'The maximum insulin units of the insulin applications', required: false }
    expose :min_glucose, documentation: { type: 'Integer', desc: 'The minimum glucose level of the insulin applications', required: false }
    expose :max_glucose, documentation: { type: 'Integer', desc: 'The maximum glucose level of the insulin applications', required: false }
  end
end
