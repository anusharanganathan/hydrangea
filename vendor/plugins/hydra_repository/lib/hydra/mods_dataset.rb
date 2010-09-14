module Hydra
  class ModsDataset < ActiveFedora::NokogiriDatastream

    set_terminology do |t|
      t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd")

      # Common MODS info -- might eventually be put into its own shared terminology.
      
      t.title_info(:path=>"titleInfo") {
        t.main_title(:path=>"title", :label=>"title")
        t.language(:path=>{:attribute=>"lang"})
      } 
      t.abstract   
      t.subject {
        t.topic
      }      
      t.topic_tag(:path=>"subject", :default_content_path=>"topic")           
      # This is a mods:name.  The underscore is purely to avoid namespace conflicts.
      t.name_ {
        # this is a namepart
        t.namePart(:index_as=>[:searchable, :displayable, :facetable, :sortable], :required=>:true, :type=>:string, :label=>"generic name")
        # affiliations are great
        t.affiliation
        t.displayForm
        t.role(:ref=>[:role])
        t.description
        t.date(:path=>"namePart", :attributes=>{:type=>"date"})
        t.last_name(:path=>"namePart", :attributes=>{:type=>"family"})
        t.first_name(:path=>"namePart", :attributes=>{:type=>"given"}, :label=>"first name")
        t.terms_of_address(:path=>"namePart", :attributes=>{:type=>"termsOfAddress"})
      }
      # lookup :person, :first_name        
      t.person(:ref=>:name, :attributes=>{:type=>"personal"})
      t.organization(:ref=>:name, :attributes=>{:type=>"institutional"})
      t.conference(:ref=>:name, :attributes=>{:type=>"conference"})

      t.role {
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
        t.code(:path=>"roleTerm",:attributes=>{:type=>"code"})
      }
      
      # Dataset-specific Terms
      
      # In datasets, we're calling the abstract "methodology"
      t.methodology(:path=>"abstract")
      
      # Most of these are forcing non-bibliographic information into mods by using the note field pretty freely
      t.note
      t.completeness(:ref=>:note, :attributes=>{:type=>"completeness"})
      t.interval(:ref=>:note, :attributes=>{:type=>"interval"})
      t.data_type(:ref=>:note, :attributes=>{:type=>"datatype"})
      t.timespan_start(:ref=>:note, :attributes=>{:type=>"timespan-start"})
      t.timespan_end(:ref=>:note, :attributes=>{:type=>"timespan-end"})
      t.location(:ref=>:note, :attributes=>{:type=>"location"})
      t.grant_number(:ref=>:note, :attributes=>{:type=>"grant"})
      t.data_quality(:ref=>:note, :attributes=>{:type=>"data quality"})
      t.contact_name(:ref=>:note, :attributes=>{:type=>"contact-name"})
      t.contact_email(:ref=>:note, :attributes=>{:type=>"contact-email"})
    end   

    # It would be nice if we could declare properties with refined info like this
    # accessor :grant_agency,  :relative_xpath=>'oxns:mods/oxns:name[contains(oxns:role/oxns:roleTerm, "Funder")]'
  
    # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
           "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
           "xmlns"=>"http://www.loc.gov/mods/v3",
           "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd") {
             xml.titleInfo {
               xml.title
             }
             xml.name(:type=>"personal") {
               xml.namePart(:type=>"given")
               xml.namePart(:type=>"family")
               xml.affiliation
               xml.role {
                 xml.roleTerm(:authority=>"marcrelator", :type=>"text")
               }
             }
             xml.name(:type=>"corporate") {
               xml.namePart
               xml.affiliation
               xml.role {
                 xml.roleTerm("Funder", :authority=>"marcrelator", :type=>"text") 
               }
             }
             xml.typeOfResource "software, multimedia"
             xml.genre("dataset", :authority=>"dct")
             xml.language {
               xml.languageTerm("eng", :authority=>"iso639-2b", :type=>"code")
             }
             xml.abstract
             xml.subject {
               xml.topic
             }
             xml.note(:type=>"completeness")
             xml.note(:type=>"interval")
             xml.note(:type=>"datatype")
             xml.note(:type=>"timespan-start")
             xml.note(:type=>"timespan-end")
             xml.note(:type=>"location")
             xml.note(:type=>"grant")
             xml.note(:type=>"data quality")
             xml.note(:type=>"contact-name")
             xml.note(:type=>"contact-email")
        }
      end
      return builder.doc
    end

    def self.person_relator_terms
       {"anl" => "Analyst",
        "aut" => "Author",
        "clb" => "Collaborator",
        "com" => "Compiler",
        "cre" => "Creator",
        "ctb" => "Contributor",
        "dpt" => "Depositor",
        "dtc" => "Data contributor ",
        "dtm" => "Data manager ",
        "edt" => "Editor",
        "lbr" => "Laboratory ",
        "ldr" => "Laboratory director ",
        "pdr" => "Project director",
        "prg" => "Programmer",
        "res" => "Researcher",
        "rth" => "Research team head",
        "rtm" => "Research team member"
        }
    end
    
    def self.interval_choices
      ["Monthly",
        "Quarterly",
        "Semi-annually",
        "Annually",
        "Irregular"
      ]
    end
    
    def self.data_type_choices
      ["transect","observation","data logging","remote sensing"]
    end
end
end