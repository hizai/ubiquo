module UbiquoDesign
  module Connectors
    class Standard < Base
      
      
      module Widget
        def self.included(klass)
          klass.send :belongs_to, :block
        end
      end

      module MenuItem
        def self.included(klass)
          
        end
      end
      
      module Page
        
        def self.included(klass)
          klass.send(:include, self::InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
        end
        
        module InstanceMethods
          
          def uhook_publish_block_widgets(block, new_block)
            block.widgets.each do |widget|
              new_widget = widget.clone
              new_widget.block = new_block
              new_widget.save_without_validation!
              yield widget, new_widget
              new_widget.save! # must validate now
            end
          end
          def uhook_publish_widget_asset_relations(widget, new_widget)
            [:asset_relations, :category_relations].each do |relation_type|
              if widget.respond_to?(relation_type)
                widget.send(relation_type).each do |relation|
                  new_relation = relation.clone
                  new_relation.related_object = new_widget
                  new_relation.save!
                end
              end
            end
          end
        end
      end
      module PagesController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods
          # Loads the page for the public part.
          # If present, uses an key to retrieve the page
          # Else uses params[:url] to decide what page to show.
          # Must return the expected Page instance or raise a not found exception.
          def uhook_load_page
            if params[:key].present?
              ::Page.published.find_by_key!(params[:key])
            else
              ::Page.published.with_url(params[:url])
            end
          end
        end
      end

      module UbiquoDesignsHelper
        def self.included(klass)
          klass.send(:helper, Helper)
        end
        module Helper
          def uhook_link_to_edit_widget(widget)
            link_to t('ubiquo.design.widget_edit'), ubiquo_page_design_widget_path(@page, widget), :class => "edit lightwindow", :type => "page", :params => "lightwindow_form=widget_edit_form,lightwindow_width=610", :id => "edit_widget_#{widget.id}"
          end
          def uhook_load_widgets(block)
            block.widgets
          end
        end        
      end
      
      module UbiquoWidgetsController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods
          
          # returns the widget for the lightwindow.
          # Will be rendered in their ubiquo/_form view
          def uhook_find_widget
            @widget = ::Widget.find(params[:id])
          end
          
          # modify the created widget and return it. It's executed in drag-drop.
          def uhook_prepare_widget(widget)
            widget
         end
          
          # Destroys a widget
          def uhook_destroy_widget(widget)
            widget.destroy
          end
          
          # updates a widget.
          # Fields can be found in params[:widget] and widget_id in params[:id]
          # must returns the updated widget
          def uhook_update_widget
            widget = ::Widget.find(params[:id])
            params[:widget].each do |field, value|
              widget.send("#{field}=", value)
            end
            widget.save
            widget
          end
        end
        module Helper
          def uhook_extra_rjs_on_update(page, valid)
            yield page
          end
        end
      end

      module UbiquoMenuItemsController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        module InstanceMethods
          
          # gets Menu items instances for the list and return it
          def uhook_find_menu_items
            ::MenuItem.roots
          end
          
          # initialize a new instance of menu item
          def uhook_new_menu_item
            ::MenuItem.new(:parent_id => (params[:parent_id] || 0), :is_active => true)
          end
          def uhook_edit_menu_item(menu_item)
            true
          end
            
          
          # creates a new instance of menu item
          def uhook_create_menu_item
            mi = ::MenuItem.new(params[:menu_item])
            mi.save
            mi
          end
          
          #updates a menu item instance. returns a boolean that means if update was done.
          def uhook_update_menu_item(menu_item)
            menu_item.update_attributes(params[:menu_item])
          end
          
          #destroys a menu item instance. returns a boolean that means if destroy was done.
          def uhook_destroy_menu_item(menu_item)
            menu_item.destroy
          end

          # loads all automatic menu items
          def uhook_load_automatic_menus
            ::AutomaticMenu.find(:all, :order => 'name ASC')  
          end
        end
        module Helper
          def uhook_extra_hidden_fields(form)
          end
          def uhook_menu_item_links(menu_item)
            links = []
            
            links << link_to(t('ubiquo.edit'), edit_ubiquo_menu_item_path(menu_item))
            links << link_to(t('ubiquo.remove'), [:ubiquo, menu_item],  
              :confirm => t('ubiquo.design.confirm_sitemap_removal'), 
              :method => :delete)
            if menu_item.can_have_children?
              links << link_to(t('ubiquo.design.new_subsection'), new_ubiquo_menu_item_path(:parent_id => menu_item))
            end
            
            links.join(" | ")
          end
        end
      end

      module UbiquoStaticPagesController
        def self.included(klass)
          klass.send(:helper, Helper)
        end
        
        module Helper
          def uhook_static_page_actions(page)
            [
              link_to(t('ubiquo.edit'), edit_ubiquo_static_page_path(page)),
              (link_to(t('ubiquo.remove'), ubiquo_static_page_path(page), :confirm => t('ubiquo.design.confirm_page_removal'), :method => :delete) unless page.key?)
            ].compact
          end
          
          def uhook_edit_sidebar
            ""
          end
        end
      end

      module UbiquoPagesController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
          klass.send(:helper, Helper)
        end
        
        module Helper
          def uhook_page_actions(page)
            [
              link_to(t('ubiquo.edit'), edit_ubiquo_page_path(page)),
              link_to(t('ubiquo.design.design'), ubiquo_page_design_path(page)),
              (link_to(t('ubiquo.remove'), [:ubiquo, page], :confirm => t('ubiquo.design.confirm_page_removal'), :method => :delete) unless page.key?)
            ].compact
          end
          
          def uhook_edit_sidebar
            ""
          end
          def uhook_new_sidebar
            ""
          end
          def uhook_form_top(form)
            ""
          end
        end
        module InstanceMethods
          
          # Returns all private pages
          def uhook_find_private_pages(filters, order_by, sort_order)
            ::Page.drafts.filtered_search(filters, :order => order_by + " " + sort_order)
          end
          
          # initializes a new instance of page.
          def uhook_new_page
            ::Page.new
          end
          
          # create a new instance of page.
          def uhook_create_page
            p = ::Page.new(params[:page])
            p.save
            p
          end
         
          #updates a page instance. returns a boolean that means if update was done.
          def uhook_update_page(page)
            page.update_attributes(params[:page])
          end

          #destroys a page isntance. returns a boolean that means if the destroy was done.
          def uhook_destroy_page(page)
            page.destroy
          end
        end
      end
      
      module RenderPage
        
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          Standard.register_uhooks klass, InstanceMethods
        end
        
        module InstanceMethods
          def uhook_collect_widgets(b, &block)
            b.widgets.collect(&block)
          end
          
          def uhook_root_menu_items
            ::MenuItem.active_roots.all
          end
          
        end
      end
      
      module Migration
        
        def self.included(klass)
          klass.send(:extend, ClassMethods)
          Standard.register_uhooks klass, ClassMethods
        end
        
        module ClassMethods
          def uhook_create_pages_table
            create_table :pages do |t|
              yield t
            end
          end
          def uhook_create_menu_items_table
            create_table :menu_items do |t|
              yield t
            end
          end
          def uhook_create_widgets_table
            create_table :widgets do |t|
              yield t
            end
          end
        end
      end
      
    end
  end
end
