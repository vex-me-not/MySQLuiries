
#1    
	select  u.Patient, p.Name , count(*)  as totalStays, sum(t.cost) as totalCost  #to SSN,to onoma ,o arithmos ton eisagogon kai to kostos
	from undergoes u,treatment t,patient p
	where p.SSN=u.Patient and u.Treatment=t.Code  and u.Stay in
		(select s1.StayID         #oi perissoteres apo 1 eisagoges ton antron ayton
		from stay s1,stay s2
		where s1.Patient=s2.Patient and s1.StayID<>s2.StayID and s1.Patient in
			(select p.SSN                     #oloi oi antres pano apo 30 kai kato apo 40
			from patient p
			where p.Gender='male' and p.Age>=30 and p.Age<=40
			order by p.SSN asc))
	group by u.Patient
	having count(*)>1;
    
 #2
	select n.EmployeeID , n.Name      #oi nosokomes poy itan stis parakato vardies
	from nurse n
	where n.EmployeeID in
		(select oc.Nurse         #oi vardies poy arxisan i teleiosan metaksi 2008... kai 2009... stoys orofous 4,5,6,7 
		from on_call oc
		where ( (oc.OnCallStart>='2008-04-20 23:22:00' and oc.OnCallStart<='2009-06-04 11:00:00') or (oc.OnCallEnd>='2008-04-20 23:22:01' and oc.OnCallEnd<='2009-06-04 11:00:00') )
			and oc.BlockFloor>=4 and oc.BlockFloor<=7
		group by oc.Nurse
		having count(*)>1)
	order by n.EmployeeID asc; 
		
#3

	select vnation.patient_SSN ,p.Name 
	from vaccination vnation, patient p, vaccines v
	where vnation.patient_SSN=p.SSN and vnation.vaccines_vax_name=v.vax_name and vnation.patient_SSN  in
			(select p.SSN     #gynaikes pano apo 40
			from patient p
			where p.Gender='female' and p.Age>40)
	group by vnation.patient_SSN,v.vax_name,v.num_of_doses
	having count(*)=v.num_of_doses
	order by p.Name
    ;

#4
	select med.Name ,med.Brand  ,count(*) as Patients       #to farmako ,i etaireia kai se posoys astheneis syntagografithike
	from prescribes pr,medication med
	where med.Code=pr.Medication
	group by pr.Medication
	having count(*)>1 ;


#5
	select vnation.patient_SSN      #oi loyal astheneis
	from vaccination vnation
	group by vnation.patient_SSN
	having count(vnation.physician_EmployeeID)=1; 

 #6
 (select "yes" as Answer
 where exists
	(select *            #ta domatia poy den xrisimopoiithikan gia eisagoges to 2013
    from room r
    where r.RoomNumber not in
		(select s.Room      #ola ta domatia poy xrisomopoiithikan gia eisagoges to 2013
		from stay s
		where  ((s.StayStart>='2013-01-01 00:00:00' and s.StayStart <= '2013-12-30 23:59:59') or (s.StayEnd>='2013-01-01 00:00:00' and s.StayEnd <= '2013-12-30 23:59:59')) 
		group by s.Room)
    order by r.RoomNumber)
  )
  union  
  (select "no" as Answer
 where not exists
	(select *            #ta domatia poy den xrisimopoiithikan gia eisagoges to 2013
    from room r
    where r.RoomNumber not in
		(select s.Room      #ola ta domatia poy xrisomopoiithikan gia eisagoges to 2013
		from stay s
		where  ((s.StayStart>='2013-01-01 00:00:00' and s.StayStart <= '2013-12-30 23:59:59') or (s.StayEnd>='2013-01-01 00:00:00' and s.StayEnd <= '2013-12-30 23:59:59')) 
		group by s.Room)
    order by r.RoomNumber)
  ) ;

#7
	(select phs.Name ,phs.EmployeeID,count(*) as PatientsTreated     #oi giatroi poy exoyn ekpedeytei sto pathology kai exoyn curarei astheneis
	from undergoes under,physician phs
	where under.Physician=phs.EmployeeID and phs.EmployeeID in
		(select ti.Physician           # oloi oi giatroi poy exoyn ekpeydeytei se treatment toy pathology
		from physician ph,trained_in ti,treatment tment
		where ph.EmployeeID=ti.Physician and tment.Code=ti.Speciality and ti.Speciality in
			(select tment.Code       # ola ta treatments poy exoyn na kanoyn me to pathology
			from treatment tment
			where tment.Name='PATHOLOGY')
		order by ti.Physician)
	group by under.Physician
	)	
union
	(select ph.Name,ph.EmployeeID , 0 as PatientsTreated          # oloi oi giatroi poy exoyn ekpeydeytei sto pathology alla den exoyn curarei kanena
	from physician ph,trained_in ti,treatment tment
	where ph.EmployeeID=ti.Physician and tment.Code=ti.Speciality 
		and ti.Speciality in
			(select tment.Code       # ola ta treatments poy exoyn na kanoyn me to pathology
			from treatment tment
			where tment.Name='PATHOLOGY') 
		
        and ti.Physician not in (
				select phs.EmployeeID      # oi giatroi poy exoyn ekpedeytei sto Pathology kai exoyn curarei astheneis
				from undergoes under,physician phs
				where under.Physician=phs.EmployeeID and phs.EmployeeID in
					(select ti.Physician           # oloi oi giatroi poy exoyn ekpeydeytei se treatment toy pathology
					from physician ph,trained_in ti,treatment tment
					where ph.EmployeeID=ti.Physician and tment.Code=ti.Speciality and ti.Speciality in
						(select tment.Code       # ola ta treatments poy exoyn na kanoyn me to pathology
						from treatment tment
						where tment.Name='PATHOLOGY')
					order by ti.Physician)
				group by under.Physician)
);
   
#8
		(select pt.Name       #oi astheneis poy exoyn emboliastei akrivos 0 fores
		from patient pt
		where pt.SSN not in(
			select vnation.patient_SSN   #oi astheneis poy exoyn emboliastei toylaxiston mia fora
			from vaccination vnation)
		)
    union
		(select p.Name          #oi astheneis poy exoyn  emboliastei ligoteres fores apo tis apaitoymenes
		from vaccination vnation ,patient p , vaccines v
		where vnation.vaccines_vax_name=v.vax_name and vnation.patient_SSN=p.SSN 
		group by vnation.patient_SSN,v.vax_name,v.num_of_doses
		having count(*)<v.num_of_doses
		);

#9
	select vc.vaccines_vax_name MostUsedVaccine
    from vaccination vc
	group by vc.vaccines_vax_name
    having count(*)>= ALL (select count(*)    #to plithos ton embolion poy exei xrisimopoiithei stoys emboliasmoys
			from vaccination vnation
			group by vnation.vaccines_vax_name
			order by count(*) desc)
    order by count(*) desc
    ;        

#10
	select ph.Name 
	from physician ph,trained_in ti,treatment tment
	where ph.EmployeeID=ti.Physician and ti.Speciality=tment.Code and tment.Name='RADIATION ONCOLOGY'
	group by ph.Name
	having count(*)=(select count(*)    #to plithos ton treatment toy rad oncology
					from treatment tment
					where tment.Name='RADIATION ONCOLOGY')
	;