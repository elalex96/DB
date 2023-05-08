

-- p_MPY_SESAceptacion 10039,1000440060,10,4500106947,10,0

CREATE Proc [dbo].[p_MPY_SESAceptacion]
@pIdContrato int,
@pSESNumber varchar(50),
@pSESLine varchar(50),
@pPO_SAPNumer varchar(50),
@pPOLineNumber varchar(50),
@pIdAceptacionPedido int out
as


	
	declare @rfcContratista varchar(15),
		@idCOntratista int,
		 @IDACEPTACIONPEDIDO int=0,
		 @nuevo bit=0

	select @rfcContratista = con.RFC,
		@idContratista = c.IdContratista
	from Adinco..CO_Contrato c
	inner join Adinco..CO_Contratista con on con.IdContratista = c.IdContratista
	where c.IdContrato = @pIdContrato

	select @IDACEPTACIONPEDIDO=isnull(aprov.IdAceptacionPedido,0)
	from  MPY_MM_AceptacionPedido aprov
		inner join Adinco..CO_SAPSES ses on rtrim(ses.SESNumber) = rtrim(@pSESNumber) And
											--ses.SESLine = @pSESLine and
											rtrim(ses.PO_SAPNumer) = rtrim(@pPO_SAPNumer) --and
											--ses.POLineNumber = @pPOLineNumber
		--inner join Adinco..CO_SAPPO po on po.SAPPONumber = ses.PO_SAPNumer and
		--						po.ItemNumber = ses.POLineNumber									
		where rtrim(aprov.IdPedido) COLLATE SQL_Latin1_General_CP1_CI_AS = rtrim(ses.PO_SAPNumer) COLLATE SQL_Latin1_General_CP1_CI_AS and
		rtrim(aprov.ServiceLineNumber) COLLATE SQL_Latin1_General_CP1_CI_AS = rtrim(ses.SESNumber) COLLATE SQL_Latin1_General_CP1_CI_AS and
		--filtrar por reference number 
		aprov.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = ses.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS

		
	
	/**********encabezado SES***************/
	if (isnull(@IDACEPTACIONPEDIDO,0) = 0)
	begin
		set @nuevo = 1

		INSERT INTO dbo.MPY_MM_AceptacionPedido
		(
		IdProveedor,	    IdSubContratista,	    IdPedido,				Comentario,
	    Activo,				Creado,				    IdDomicilioEntrega,	    CreadorPor,
	    Version,		    CostObject,			    MaterialGroup,		    MaterialgroupDesc2,
	    Qty,			    Price,				    costobject2,		    ServiceGroup,
		IdContrato,			VendorsName ,			VendorAddress ,			Contacto  ,
		CorreoContacto,		PaisSAP ,				ServiceLineNumber,		ShortText,
		ParentLineUOM,		ServiceShortText,		ServicesUOM,			ReferenceNumber
		)
		select @idContratista,ven.VendorIDSAP,po.SAPPONumber,			PO.Comments,
		1,					getdate(),				po.DeliveryAddress,		1,
		po.VersionNumber,	ses.CostObject,			ses.MaterialGroup,		ses.MaterialGroupDesc2,
		ses.Quantity,		ses.UnitPrice,			po.CostObject2,			po.ServiceGroup,
		@pidContrato,		ven.VendorName,			ven.Address,			ven.ContactName,
		ven.ContactEmail,	ven.Country,			ses.SESNumber,	po.ShortText,
		po.ParentLineUOM,	po.ServiceShortText,	po.ServicesUOM,			ses.SESReferenceNumber
		from Adinco..CO_SAPSES ses 
		inner join Adinco..CO_SAPPO po on po.SAPPONumber = ses.PO_SAPNumer and
								po.ItemNumber = ses.POLineNumber	
		left join Adinco..CO_SAPVendor ven	on ven.VendorIDSAP = 	po.SAPVendorNumber						
		where ses.SESNumber = @pSESNumber And
											ses.SESLine = @pSESLine and
											ses.PO_SAPNumer = @pPO_SAPNumer and
											ses.POLineNumber = @pPOLineNumber 


		SET @IDACEPTACIONPEDIDO = scope_identity()

		set @pIdAceptacionPedido= @IDACEPTACIONPEDIDO
	end
	Else
	Begin
		set @pIdAceptacionPedido= @IDACEPTACIONPEDIDO

		update MPY_MM_AceptacionPedido
		set Comentario=PO.Comments,			    IdDomicilioEntrega = po.DeliveryAddress,	    
			Version = po.VersionNumber,			CostObject=ses.CostObject,			    
			MaterialGroup=ses.MaterialGroup,	MaterialgroupDesc2 = ses.MaterialGroupDesc2,
			Qty=ses.Quantity,					Price=ses.UnitPrice,				    
			costobject2=po.CostObject2,			ServiceGroup=po.ServiceGroup,
		 	VendorsName =ven.VendorName,		VendorAddress=ven.Address ,			
			Contacto = ven.ContactName,			CorreoContacto=ven.ContactEmail,		
			PaisSAP =ven.Country,				ShortText = po.ShortText,
			ParentLineUOM=po.ParentLineUOM,		ServiceShortText=po.ServiceShortText,		
			ServicesUOM=po.ServicesUOM,
			ReferenceNumber = ses.SESReferenceNumber
		from MPY_MM_AceptacionPedido aprov
		inner join Adinco..CO_SAPSES ses  on ses.SESNumber = @pSESNumber And
											ses.SESLine = @pSESLine and
											ses.PO_SAPNumer = @pPO_SAPNumer and
											ses.POLineNumber = @pPOLineNumber 
		inner join Adinco..CO_SAPPO po on po.SAPPONumber = ses.PO_SAPNumer and
								po.ItemNumber = ses.POLineNumber	
		left join Adinco..CO_SAPVendor ven	on ven.VendorIDSAP = 	po.SAPVendorNumber				
		where aprov.IdAceptacionPedido = @IDACEPTACIONPEDIDO
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
			ses.Currency,			
			ses.UOM,

			ses.PO_SAPNumer,
			ses.SESLine,
			ses.MaterialGroupDesc2,
			ses.MaterialGroupDesc2
		
	from MPY_MM_AceptacionPedido aprov
	inner join Adinco..CO_SAPSES ses on ses.SESNumber = @pSESNumber And
											ses.SESLine = @pSESLine and
											ses.PO_SAPNumer = @pPO_SAPNumer and
											ses.POLineNumber = @pPOLineNumber
	where aprov.IdAceptacionPedido = @IDACEPTACIONPEDIDO	
	and not exists(
		select 1
		from MPY_MM_AceptacionPedidoDetalle s1
		where s1.IdAceptacionPedido  = aprov.IdAceptacionPedido and
		s1.SAPNumber Collate SQL_Latin1_General_CP1_CI_AS = ses.PO_SAPNumer Collate SQL_Latin1_General_CP1_CI_AS and
		s1.Partida Collate SQL_Latin1_General_CP1_CI_AS = ses.SESLine Collate SQL_Latin1_General_CP1_CI_AS

	)

	--Actualizar
	UPDATE [MPY_MM_AceptacionPedidoDetalle]
	SET [Cantidad] = ses.Quantity
           ,[Detalle]=ses.MaterialGroupDesc2           
           ,[PrecioUnitario]=ses.UnitPrice
           ,[IdMoneda]=ses.Currency
           ,[Unidad]=       ses.UOM 
           ,[SAPNumber]=ses.PO_SAPNumer
           --,[Partida]=ses.SESLine
           ,[DescripcionCorta]=ses.MaterialGroupDesc2
           ,[DescripcionLarga]=ses.MaterialGroupDesc2
	FROM [MPY_MM_AceptacionPedidoDetalle] t1
	inner join Adinco..CO_SAPSES ses on ses.SESNumber = @pSESNumber And
											ses.SESLine = @pSESLine and
											ses.PO_SAPNumer = @pPO_SAPNumer and
											ses.POLineNumber = @pPOLineNumber and
											t1.Partida COLLATE SQL_Latin1_General_CP1_CI_AS= ses.SESLine COLLATE SQL_Latin1_General_CP1_CI_AS
	left join [MPY_MM_AceptacionCartaPCN] carta on carta.IdAceptacionPedido = t1.IdAceptacionPedido and
												carta.IdEstatus in (1,2)
	where t1.IdAceptacionPedido = @pIdAceptacionPedido and
	carta.IdAceptacionPedido is null

	
	set @pIdAceptacionPedido = isnull(@pIdAceptacionPedido,0)
	
	





