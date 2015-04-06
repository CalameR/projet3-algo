procedure Ajout_Sortant( Tab_Coordonnees :in Coordonnees_Points, Indice : in Integer,  ABR : in out Arbre ) is
   Indice_Sup, Indice_Inf : Integer ;
begin
   case Indice is
      when 1 => Indice_Inf := Tab_Coordonnees'Last ;
	 Indice_Sup := 2 ;
      when Tab_Coordonnees'Last => Indice_Inf := Tab_Coordonnees'Last - 1 ;
	 Indice_Sup := 1 ;
      when others => Indice_Inf := Indice - 1 ;
	 Indice_Sup := Indice + 1 ;
   end case;
   
   if (  Tab_Coordonnees(Indice).X <= Tab_Coordonnees(Indice_Sup).X ) then 
      Insertion(ABR,(Tab_Coordonnees(Indice), Tab_Coordonnees(Indice_Sup)) ;
		end if ;
		if ( Tab_Coordonnees(Indice).X <= Tab_Coordonnees(Indice_Inf).X ) then 
      Insertion(ABR,(Tab_Coordonnees(Indice), Tab_Coordonnees(Indice_Inf)) ;
		end if ;
		end;
		
procedure Retirer_Sortant( Tab_Coordonnees :in Coordonnees_Points, Indice : in Integer,  ABR : in out Arbre ) is
   Indice_Sup, Indice_Inf : Integer ;
begin
   case Indice is
      when 1 => Indice_Inf := Tab_Coordonnees'Last ;
	 Indice_Sup := 2 ;
      when Tab_Coordonnees'Last => Indice_Inf := Tab_Coordonnees'Last - 1 ;
	 Indice_Sup := 1 ;
      when others => Indice_Inf := Indice - 1 ;
	 Indice_Sup := Indice + 1 ;
   end case;
   
   if (  Tab_Coordonnees(Indice).X <= Tab_Coordonnees(Indice_Sup).X ) then 
      Insertion(ABR,(Tab_Coordonnees(Indice), Tab_Coordonnees(Indice_Sup)) ;
		end if ;
		if ( Tab_Coordonnees(Indice).X <= Tab_Coordonnees(Indice_Inf).X ) then 
      Insertion(ABR,(Tab_Coordonnees(Indice), Tab_Coordonnees(Indice_Inf)) ;
		end if ;
		end;
		
			     

procedure Parcours( Tab_Coordonnees :in Coordonnees_Points, ABR : in out Arbre, Fichier : in out File_Type ) is
   Abscisse : Float ;
   Liste_Tri_Sommet_Abscisse : Liste_Abscisse_Sommet := ( null, null );               -- Tableau contenant la donnée d'intersection ou non entre les segments et la droite verticale
   Courant : Pointeur_Tete ;
   Rebroussement : Boolean := False ;
begin
   Liste_Tri_Sommet_Abscisse.Tete := new Cellule_Abscisse'( 1 , Tab_Coordonnees(1).X, null );
   Liste_Tri_Sommet_Abscisse.Queue := Liste_Tri_Sommet_Abscisse.Tete;
   for I in 2..Tab_Coordonnees'Last loop          
      Liste_Tri_Sommet_Abscisse.Tete := new Cellule_Abscisse'( I , Tab_Coordonnees(I).X, Liste_Tri_Sommet_Abscisse.Tete  ); ;
   end loop;
   Tri_Fusion_Liste_Abscisse_Sommet( L_Tri_Sommet_Abscisse );
   Courant := Liste_Tri_Sommet_Abscisse.Tete ;
   Ajout_Sortant( Tab_Coordonnees, Courant.Indice, ABR );
   Courant := Courant.Suiv ;
   Ajout_Sortant( Tab_Coordonnees, Courant.Indice, ABR );
   Retirer_Entrant(  Tab_Coordonnees, Courant.Indice, ABR );
   while Courant /= Liste_Tri_Sommet_Abscisse.Queue loop                                          -- on parcourt le polygone de l'extrémité gauche à l'extrémité droite
      Courant := Courant.Suiv ;
      Abscisse := Tab_Coordonnees( Courant.Indice ).X;
      Intersection( Tab_Coordonnees, Tab_Seg, Abscisse, ABR );            -- mise à jour de l'ABR avec le changement d'abscisse de la droite
	 if Compte(ABR) >= 4 then                                         -- rebroussement comme extrémité commune
	    Tracer(Tab_Coordonnees, ABR, Abscisse, Fichier ) ;                      -- on ajoute le segment pour délimiter en polygones monotones
	 end if;                             
   end loop ;
   Detruire(ABR);               -- on libère l'espace mémoire                                
end Parcours;

procedure Separation(L_Init : in Liste_Abscisse_Sommet ; L_New_1 : out Liste_Abscisse_Sommet ; L_New_2 : out Liste_Abscisse_Sommet ) is
   Courant : Pointeur_Sommet ;
   Partage : Boolean := True  ;
begin
   
   Courant := L_Init.Tete ;
   L_New_1 := (null,null) ;
   L_New_2 := (null,null) ;
   
   while (Courant /= null) loop
      
      if Partage then
	 
	 L_New_1.Tete := new Cellule_Abscisse'( Courant.Indice, Courant.Abscisse, L_New_1.Tete ) ;
	 
	 if ( L_New_1.Queue = null ) then
	    L_New_1.Queue := L_New_1.Tete ;
	 end if ;
		    
      else 
	 
	 L_New_2.Tete := new Cellule_Abscisse'( Courant.Indice,  Courant.Abscisse, L_New_2.Tete ) ; 
	 
	 if ( L_New_2.Queue = null ) then
	    L_New_2.Queue := L_New_2.Tete ;
	 end if ;
	 
      end if ;
      
      Courant :=  Courant.Suiv ;
      Partage := not Partage ;
      
   end loop ;
   
end Separation ;



procedure Fusion( L_Init_1 : in Liste_Abscisse_Sommet ; L_Init_2 : in Liste_Abscisse_Sommet ; L_New : out Liste_Abscisse_Sommet ) is
   Courant_1, Courant_2, Courant_New : Pointeur_Abscisse ;
begin
		
   Courant_1 := L_Init_1.Tete ;
   Courant_2 := L_Init_2.Tete ;
   
   if ( Courant_1.Abscisse < Courant_2.Abscisse ) then
      L_New.Tete := Courant_1 ;
      Courant_1 := Courant_1.Suiv ;
   else
      L_New.Tete := Courant_2 ;
      Courant_2 := Courant_2.Suiv ;
   end if ;
   
   Courant_New := L_New.Tete ;
       
       
       
   while ( Courant_1 /= null ) and  ( Courant_2 /= null ) loop
      
      if ( Courant_1.Abscisse < Courant_2.Abscisse ) then
	 Courant_New.Suiv := Courant_1 ;
	 Courant_New := Courant_New.Suiv ;
	 Courant_1 := Courant_1.Suiv ;
	 
      else
	 
	 Courant_New.Suiv := Courant_2 ;
	 Courant_New := Courant_New.Suiv ;
	 Courant_2 := Courant_2.Suiv ;
	 
      end if ;
      
   end loop ;
   
   if ( Courant_1 = null ) then 
      Courant_New.Suiv := Courant_2 ;
      L_New.Queue := L_Init_2.Queue ;
   else
      Courant_New.Suiv := Courant_1 ;
      L_New.Queue := L_Init_1.Queue ;
   end if ;
   
   
end Fusion ;



procedure Tri_Fusion_Liste_Abscisse_Sommet( L_Abscisse_Sommet : in out Liste_Abscisse_Sommet ) is
   L_New_1, L_New_2 : Liste_Abscisse_Sommet ;
begin
   
   if ( L_Abscisse_Sommet.Tete /= L_Abscisse_Sommet.Queue ) then
      Separation( L_Abscisse_Sommet, L_New_1, L_New_2 );
      Tri_Fusion_Liste_Abscisse_Sommet(L_New_1);
      Tri_Fusion_Liste_Abscisse_Sommet(L_New_2);				
      Fusion(L_New_1, L_New_2, L_Abscisse_Sommet);
   end if ;
       
   
end Tri_Fusion_Liste_Abscisse_Sommet ;
    
procedure Modifier_Tableau_Rebroussement( Tab_Coordonnees : in Coordonnees_Points, Tab_Rebroussement : out Tab_Sommet_Bool_Sens, Indice : in Integer, Indice_inf : in Integer, Indice_sup : in Integer ) is 
begin
      if ( Tab_Coordonnees(Indice).X >= Tab_Coordonnees(Indice_sup).X ) and (  Tab_Coordonnees(Indice).X >= Tab_Coordonnees(Indice_inf).X ) then 
	 Tab_Rebroussement(Indice).Bool := True ;
	 Tab_Rebroussement(Indice).Sens := Avant ;
      else
	 if (  Tab_Coordonnees(Indice).X <= Tab_Coordonnees(Indice_sup).X ) and (  Tab_Coordonnees(I).X <= Tab_Coordonnees(Indice_inf).X ) then 
	    Tab_Rebroussement(Indice).Bool := True ;
	    Tab_Rebroussement(Indice).Sens := Apres ; 
	 else
	    Tab_Rebroussement(Indice).Bool := False ;
	 end if ;
      end if ;   
end ;
      
procedure Remplir_Tableau_Rebroussement( Tab_Coordonnees : in Coordonnees_Points, Tab_Rebroussement : out Tab_Sommet_Bool_Sens ) is 
begin
   for 2..( Tab_Rebroussement'Last - 1 ) loop
      Modifier_Tableau_Rebroussement( Tab_Coordonnees, Tab_Rebroussement, I, I - 1 , I + 1 );
   end loop ;
   Modifier_Tableau_Rebroussement( Tab_Coordonnees, Tab_Rebroussement, 1, Tab_Rebroussement'Last , 2  );
   Modifier_Tableau_Rebroussement( Tab_Coordonnees, Tab_Rebroussement, Tab_Rebroussement'Last, Tab_Rebroussement'Last - 1 , 1  );
end ;

       
       procedure Tracer( Tab_Coordonnees : in Coordonnees_Points , ABR : in Arbre, Abscisse : in Float, Fichier : in out File_Type ) is
       begin
	  Open ( File => File,
		 Mode => Ada.Text_IO.In_File,
		 Fichier => Filename);
   
	  
	  
	    
   
