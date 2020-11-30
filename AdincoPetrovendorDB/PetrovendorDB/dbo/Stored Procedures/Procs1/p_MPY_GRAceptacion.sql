-- p_MPY_GRAceptacion 3,'4500092975',80,'20190305',0
CREATE Proc [dbo].[p_MPY_GRAceptacion]
@pIdContrato int,
@pPO_SAPNumber varchar(50),
@pPOLineNumber varchar(50),
@pDocumentDate varchar(15),
@pIdAceptacionPedido int out
as

	declare @rfcContratista varchar(15),
		@idCOntratista int,
		 @IDACEPTACIONPEDIDO int

	select @rfcContratista = con.RFC,
		@idContratista = c.IdContratista
	from Adinco..CO_Contrato c
	inner join Adinco..CO_Contratista con on con.IdContratista = c.IdContratista
	where c.IdContrato = @pIdContrato

	select @IDACEPTACIONPEDIDO=aprov.IdAceptacionPedido
	from  MPY_MM_AceptacionPedido aprov
		inner join Adinco..CO_SAPGR ses on ses.PO_SAPNumber = @pPO_SAPNumber and
											ses.DocumentDate =  @pDocumentDate--And
											--ses.POLineNumber = @pPOLineNumber 
		inner join Adinco..CO_SAPPO po on po.SAPPONumber = ses.PO_SAPNumber and
								po.ItemNumber = ses.POLineNumber									
	where aprov.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = ses.PO_SAPNumber COLLATE SQL_Latin1_General_CP1_CI_AS and
	aprov.DocumentDate COLLATE SQL_Latin1_General_CP1_CI_AS =  ses.DocumentDate COLLATE SQL_Latin1_General_CP1_CI_AS--and
	--aprov.ServiceLineNumber COLLATE SQL_Latin1_General_CP1_CI_AS = ses.POLineNumber COLLATE SQL_Latin1_General_CP1_CI_AS


	/**********encabezado SES***************/
	if (isnull(@IDACEPTACIONPEDIDO,0) = 0)
	begin
		INSERT INTO dbo.MPY_MM_AceptacionPedido
		(
		IdProveedor,	    IdSubContratista,	    IdPedido,				Comentario,
	    Activo,				Creado,				    IdDomicilioEntrega,	    CreadorPor,
	    Version,		    CostObject,			    MaterialGroup,		    MaterialgroupDesc2,
	    Qty,			    Price,				    costobject2,		    ServiceGroup,
		IdContrato,			VendorsName ,			VendorAddress ,			Contacto  ,
		CorreoContacto,		PaisSAP ,				ServiceLineNumber,		ShortText,
		ParentLineUOM,		ServiceShortText,		ServicesUOM,			ReferenceNumber,
		DocumentDate
		)
		select @idCOntratista,ven.VendorIDSAP,		po.SAPPONumber,			PO.Comments,
		1,					getdate(),				po.DeliveryAddress,		1,
		po.VersionNumber,	ses.CostObject,			ses.MaterialGroup,		ses.MaterialGroupDesc2,
		ses.Quantity,		ses.UnitPrice,			po.CostObject2,			po.ServiceGroup,
		@pidContrato,		ven.VendorName,			ven.Address,			ven.ContactName,
		ven.ContactEmail,	ven.Country,			min(po.ItemNumber),	po.ShortText,
		po.ParentLineUOM,	po.ServiceShortText,	po.ServicesUOM,			GRReferenceNumber,
		@pDocumentDate
		from Adinco..CO_SAPGR ses 
		inner join Adinco..CO_SAPPO po on po.SAPPONumber = ses.PO_SAPNumber and
								po.ItemNumber = ses.POLineNumber	
		inner join Adinco..CO_SAPVendor ven	on ven.VendorIDSAP = 	po.SAPVendorNumber						
		where ses.PO_SAPNumber = @pPO_SAPNumber And
								ses.POLineNumber = @pPOLineNumber 
		--Se agregó esta validación para evitar duplicar aceptaciones, por el nuevo cambio de llave primaria en la tabla CO_SAPGR
		and not exists (
			select 1
			from MPY_MM_AceptacionPedidoDetalle st1
			inner join [MPY_MM_AceptacionPedido] st2 on st2.IdPedido COLLATE Modern_Spanish_CI_AS = ses.PO_SAPNumber COLLATE Modern_Spanish_CI_AS
			where st1.IdAceptacionPedido = st2.IdAceptacionPedido and
			st1.[Partida] COLLATE Modern_Spanish_CI_AS = ses.POLineNumber  COLLATE Modern_Spanish_CI_AS and
			st1.Cantidad = ses.Quantity
			
		)
		group by ven.VendorIDSAP,		po.SAPPONumber,			PO.Comments,
		po.DeliveryAddress,			po.VersionNumber,	ses.CostObject,			
		ses.MaterialGroup,		ses.MaterialGroupDesc2,	ses.Quantity,		
		ses.UnitPrice,			po.CostObject2,			po.ServiceGroup,
		ven.VendorName,			ven.Address,			ven.ContactName,
		ven.ContactEmail,	ven.Country,			po.ShortText,			po.ParentLineUOM,	
		po.ServiceShortText,	po.ServicesUOM,			GRReferenceNumber


		SET @IDACEPTACIONPEDIDO = scope_identity()

		set @pIdAceptacionPedido= @IDACEPTACIONPEDIDO
	end
	Else
	Begin

		set @pIdAceptacionPedido= @IDACEPTACIONPEDIDO

		update MPY_MM_AceptacionPedido
		set Comentario=PO.Comments,			    IdDomicilioEntrega = po.DeliveryAddress,	    
			Version = po.VersionNumber,	    CostObject=ses.CostObject,			    
			MaterialGroup=ses.MaterialGroup,	MaterialgroupDesc2 = ses.MaterialGroupDesc2,
			Qty=ses.Quantity,					Price=ses.UnitPrice,				    
			costobject2=po.CostObject2,		 ServiceGroup=po.ServiceGroup,
		 	VendorsName =ven.VendorName,		VendorAddress=ven.Address ,			
			Contacto = ven.ContactName,			CorreoContacto=ven.ContactEmail,		
			PaisSAP =ven.Country,				ShortText = po.ShortText,
			ParentLineUOM=po.ParentLineUOM,		ServiceShortText=po.ServiceShortText,		
			ServicesUOM=po.ServicesUOM,
			ReferenceNumber = case when aprov.ReferenceNumber COLLATE Modern_Spanish_CI_AS is null then ses.GRReferenceNumber COLLATE Modern_Spanish_CI_AS  else aprov.ReferenceNumber COLLATE Modern_Spanish_CI_AS end
		from MPY_MM_AceptacionPedido aprov
		inner join Adinco..CO_SAPGR ses on ses.PO_SAPNumber = @pPO_SAPNumber --And
											--ses.POLineNumber = @pPOLineNumber 
		inner join Adinco..CO_SAPPO po on po.SAPPONumber = ses.PO_SAPNumber and
								po.ItemNumber = ses.POLineNumber		
		inner join Adinco..CO_SAPVendor ven	on ven.VendorIDSAP = 	po.SAPVendorNumber						
		where aprov.IdAceptacionPedido = @IDACEPTACIONPEDIDO
		and aprov.IdAceptacionPedido not in (99,712)

	End


	/*************Detalle SES*************************/
	INSERT INTO [dbo].[MPY_MM_AceptacionPedidoDetalle]
           ([IdAceptacionPedido]
           ,[Cantidad]
           ,[Detalle]
           ,[CreadoPor]
           ,[Creado]
           ,[PrecioUnitario]
           ,[IdMoneda]
           ,[Unidad]

        
           ,[SAPNumber]
           ,[Partida]
           ,[DescripcionCorta]
           ,[DescripcionLarga])
	select aprov.IdAceptacionPedido,
			ses.Quantity,
			ses.MaterialGroupDesc2,
			1,
			getdate(),
			ses.UnitPrice,
			po.Currency,			
			ses.UOM,

			ses.PO_SAPNumber,
			ses.POLineNumber,
			ses.MaterialGroupDesc2,
			ses.MaterialGroupDesc2
		
	from MPY_MM_AceptacionPedido aprov
	inner join Adinco..CO_SAPGR ses on ses.PO_SAPNumber = @pPO_SAPNumber --And
											--ses.POLineNumber = @pPOLineNumber 
	inner join Adinco..CO_SAPPO po on po.SAPPONumber = ses.PO_SAPNumber and
								po.ItemNumber = ses.POLineNumber		
	where aprov.IdAceptacionPedido = @IDACEPTACIONPEDIDO
	--and aprov.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = ses.PO_SAPNumber COLLATE SQL_Latin1_General_CP1_CI_AS --and
		--aprov.ServiceLineNumber COLLATE SQL_Latin1_General_CP1_CI_AS = ses.POLineNumber COLLATE SQL_Latin1_General_CP1_CI_AS
	and not exists(
		select 1
		from MPY_MM_AceptacionPedidoDetalle s1
		where s1.IdAceptacionPedido  = aprov.IdAceptacionPedido and
		--s1.SAPNumber Collate SQL_Latin1_General_CP1_CI_AS = ses.PO_SAPNumber Collate SQL_Latin1_General_CP1_CI_AS and
		s1.Partida Collate SQL_Latin1_General_CP1_CI_AS = ses.POLineNumber Collate SQL_Latin1_General_CP1_CI_AS

	)
	--Se agregó esta validación para evitar duplicar aceptaciones, por el nuevo cambio de llave primaria en la tabla CO_SAPGR
		and not exists (
			select 1
			from MPY_MM_AceptacionPedidoDetalle st1
			inner join [MPY_MM_AceptacionPedido] st2 on st2.IdPedido COLLATE Modern_Spanish_CI_AS = ses.PO_SAPNumber COLLATE Modern_Spanish_CI_AS
			where st1.IdAceptacionPedido = st2.IdAceptacionPedido and
			st1.[Partida] COLLATE Modern_Spanish_CI_AS = ses.POLineNumber COLLATE Modern_Spanish_CI_AS and
			st1.Cantidad = ses.Quantity
			
		)
	






	set @pIdAceptacionPedido = isnull(@pIdAceptacionPedido,0)