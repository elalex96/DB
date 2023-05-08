

CREATE proc [dbo].[p_COSAP_RecalcularContrato]
as

		select a.IdContratista,
		IdContrato = MAX(c.IdContrato)
		into #tmpContratos 
		from [CO_SAPContratista_Planta] a
		inner join CO_Contrato c on c.IdContratista = a.IdCOntratista 
		GROUP BY a.IdContratista

		select SAPPONumber,ItemNumber ,IdContratoDel = Min(IdContrato)
		into #tmpPODel
		from CO_SAPPO
		group by SAPPONumber,ItemNumber
		having count(*) > 1

		delete CO_SAPPO
		from CO_SAPPO t1
		inner join #tmpPODel t2 on t2.SAPPONumber = t1.SAPPONumber and
							t2.ItemNumber = t1.ItemNumber and
							t2.IdContratoDel = t1.IdContrato



		select po.SAPPONumber,
		po.ItemNumber,
		IdContrato = po.IdContrato,
		IdContrato2 = tmp.IdContrato,
		prov.IdProveedor,
		cp.IdContratista
		into #tmpPOContrato
		from CO_SAPPO po
		inner join [dbo].[CO_SAPContratista_Planta] cp on cp.Planta = po.Plant 
		inner join #tmpContratos tmp on tmp.IdContratista = cp.IdCOntratista
		inner join CO_Contratista con on con.IdContratista = cp.IdContratista
		inner join Petrovendor..S_Proveedor prov on prov.RFC collate Modern_Spanish_CI_AS= con.RFC collate Modern_Spanish_CI_AS

		

		print 'update CO_SAPPO'

		update CO_SAPPO 
		set IdContrato = t2.IdContrato2
		from CO_SAPPO t1
		inner join #tmpPOContrato t2 on t2.SAPPONUmber = t1.SAPPONUmber and
		t2.ItemNUmber = t1.ItemNumber and
		t2.IdContrato = t1.IdContrato and
		t2.IdContrato2 <> t1.IdContrato 

		print 'update CO_SAPSES'

		update CO_SAPSES 
		set IdContrato = t2.IdContrato2
		from CO_SAPSES t1
		inner join #tmpPOContrato t2 on t2.SAPPONUmber = t1.po_SAPNumer and
		t2.ItemNUmber = t1.POLineNumber and
		t2.IdContrato = t1.IdContrato and
		t2.IdContrato2 <> t1.IdContrato 

		print 'update CO_SAPGR'

		update CO_SAPGR 
		set IdContrato = t2.IdContrato2
		from CO_SAPGR t1
		inner join #tmpPOContrato t2 on t2.SAPPONUmber = t1.po_SAPNumber and
		t2.ItemNUmber = t1.POLineNumber and
		t2.IdContrato = t1.IdContrato and
		t2.IdContrato2 <> t1.IdContrato

		print 'MPY_MM_AceptacionPedido'

		update Petrovendor..MPY_MM_AceptacionPedido
		set IdCOntrato = t2.IdContrato2,
		IdProveedor = t2.IdContratista
		 from Petrovendor..MPY_MM_AceptacionPedido t1
		inner join #tmpPOContrato t2 on t2.SAPPONUmber collate Modern_Spanish_CI_AS = t1.IdPedido collate Modern_Spanish_CI_AS and
		t2.IdContrato = t1.IdContrato and
		t2.IdContrato2 <> t1.IdContrato

		drop table #tmpPOContrato

		drop table #tmpContratos