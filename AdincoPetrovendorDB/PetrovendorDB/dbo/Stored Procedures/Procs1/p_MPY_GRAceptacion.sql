IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_MPY_GRAceptacion'
)
    DROP PROCEDURE p_MPY_GRAceptacion
GO
CREATE Proc [dbo].[p_MPY_GRAceptacion]
    @pIdContrato int,
    @pPO_SAPNumber varchar(50),
    @pPOLineNumber varchar(50),
    @pDocumentDate varchar(15),
    @pIdAceptacionPedido int out
AS
BEGIN
    declare @rfcContratista varchar(15),
            @idCOntratista int

    select @rfcContratista = CO_Contratista.RFC,
           @idContratista = CO_Contrato.IdContratista
    from Adinco..CO_Contrato (NOLOCK) 
        inner join Adinco..CO_Contratista (NOLOCK)
            on CO_Contratista.IdContratista = CO_Contrato.IdContratista
    where CO_Contrato.IdContrato = @pIdContrato


    select top 1
        @pIdAceptacionPedido = MPY_MM_AceptacionPedido.IdAceptacionPedido
    from petrovendor..MPY_MM_AceptacionPedido (NOLOCK)
        inner join Adinco..CO_SAPGR (NOLOCK)
            on MPY_MM_AceptacionPedido.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PO_SAPNumber
               and CO_SAPGR.PO_SAPNumber = @pPO_SAPNumber
               and CO_SAPGR.DocumentDate = @pDocumentDate
               and CO_SAPGR.Quantity >= 0
               and LTRIM(RTRIM(UPPER(MPY_MM_AceptacionPedido.ReferenceNumber))) COLLATE DATABASE_DEFAULT = LTRIM(RTRIM(UPPER(CO_SAPGR.GRReferenceNumber)))
        inner join Adinco..CO_SAPPO (NOLOCK)
            on CO_SAPPO.SAPPONumber = @pPO_SAPNumber
               and CO_SAPPO.SAPPONumber = CO_SAPGR.PO_SAPNumber
               and CO_SAPGR.POLineNumber = CO_SAPPO.ItemNumber
        left JOIN Adinco..CO_SAPPRESES (NOLOCK)
            ON CO_SAPPO.SAPVendorNumber = CO_SAPPRESES.SAPVendorNumber
               AND CO_SAPPO.SAPPONumber = CO_SAPPRESES.SAPPONumber
               AND LTRIM(RTRIM(UPPER(CO_SAPGR.GRReferenceNumber))) = LTRIM(RTRIM(UPPER(CO_SAPPRESES.SAPSESNumber)))
    where MPY_MM_AceptacionPedido.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = CO_SAPGR.PO_SAPNumber COLLATE SQL_Latin1_General_CP1_CI_AS
          and MPY_MM_AceptacionPedido.DocumentDate COLLATE SQL_Latin1_General_CP1_CI_AS = CO_SAPGR.DocumentDate COLLATE SQL_Latin1_General_CP1_CI_AS
          and CO_SAPGR.Quantity >= 0
          and MPY_MM_AceptacionPedido.IdContrato = @pIdContrato

    /**********encabezado SES***************/
    if (isnull(@pIdAceptacionPedido, 0) = 0)
    begin

        INSERT INTO dbo.MPY_MM_AceptacionPedido
		(
		IdProveedor,		IdSubContratista,		IdPedido,		Comentario,			Activo,			Creado, 
		IdDomicilioEntrega, CreadorPor,				Version,		CostObject,			MaterialGroup, 
		MaterialgroupDesc2, Qty,					Price,			costobject2,		ServiceGroup,	IdContrato, 
		VendorsName,		VendorAddress,			Contacto,		CorreoContacto,		PaisSAP, 
		ServiceLineNumber,	ShortText,				ParentLineUOM,	ServiceShortText,	ServicesUOM,	ReferenceNumber, DocumentDate)
select	@idCOntratista,		CO_SAPVendor.VendorIDSAP,	CO_SAPPO.SAPPONumber, 
		CO_SAPPO.Comments, 1, getdate(), CO_SAPPO.DeliveryAddress, 1, 
		CO_SAPPO.VersionNumber, CO_SAPGR.CostObject, CO_SAPGR.MaterialGroup, 
		CO_SAPGR.MaterialGroupDesc2, CO_SAPGR.Quantity, CO_SAPGR.UnitPrice, 
		CO_SAPPO.CostObject2, CO_SAPPO.ServiceGroup, @pidContrato, CO_SAPVendor.VendorName, 
		CO_SAPVendor.Address, CO_SAPVendor.ContactName, CO_SAPVendor.ContactEmail, 
		CO_SAPVendor.Country, min(CO_SAPPO.ItemNumber), CO_SAPPO.ShortText, CO_SAPPO.ParentLineUOM, 
		CO_SAPPO.ServiceShortText, CO_SAPPO.ServicesUOM, GRReferenceNumber, @pDocumentDate
		from Adinco..CO_SAPGR(NOLOCK)
			 inner join Adinco..CO_SAPPO(NOLOCK) on CO_SAPPO.SAPPONumber=CO_SAPGR.PO_SAPNumber 
				and CO_SAPPO.ItemNumber=CO_SAPGR.POLineNumber 
				and CO_SAPGR.DocumentDate=@pDocumentDate
			 inner join Adinco..CO_SAPVendor(NOLOCK) on CO_SAPVendor.VendorIDSAP=CO_SAPPO.SAPVendorNumber
			 left join Adinco..CO_SAPPRESES(NOLOCK) on CO_SAPPRESES.ItemNumber=@pPOLineNumber 
				and CO_SAPPRESES.SAPPONumber=CO_SAPPO.SAPPONumber 
				and LTRIM(RTRIM(UPPER(CO_SAPPRESES.SAPSESNumber)))=LTRIM(RTRIM(UPPER(CO_SAPGR.GRReferenceNumber)))
			 left join MPY_MM_AceptacionPedido(NOLOCK) on MPY_MM_AceptacionPedido.IdPedido=@pPO_SAPNumber 
				and MPY_MM_AceptacionPedido.DocumentDate=@pDocumentDate 
				and LTRIM(RTRIM(UPPER(MPY_MM_AceptacionPedido.ReferenceNumber)))COLLATE DATABASE_DEFAULT=LTRIM(RTRIM(UPPER(CO_SAPGR.GRReferenceNumber)))
		where CO_SAPGR.PO_SAPNumber=@pPO_SAPNumber And CO_SAPGR.POLineNumber=@pPOLineNumber and CO_SAPGR.Quantity>=0 and MPY_MM_AceptacionPedido.IdAceptacionPedido is null
		group by CO_SAPVendor.VendorIDSAP, CO_SAPPO.SAPPONumber, CO_SAPPO.Comments, CO_SAPPO.DeliveryAddress, 
		CO_SAPPO.VersionNumber, CO_SAPGR.CostObject, CO_SAPGR.MaterialGroup, CO_SAPGR.MaterialGroupDesc2, 
		CO_SAPGR.Quantity, CO_SAPGR.UnitPrice, CO_SAPPO.CostObject2, CO_SAPPO.ServiceGroup, CO_SAPVendor.VendorName, 
		CO_SAPVendor.Address, CO_SAPVendor.ContactName, CO_SAPVendor.ContactEmail, CO_SAPVendor.Country, 
		CO_SAPPO.ShortText, CO_SAPPO.ParentLineUOM, CO_SAPPO.ServiceShortText, CO_SAPPO.ServicesUOM, GRReferenceNumber


        select @pIdAceptacionPedido = scope_identity()


    end


    /*************Detalle SES*************************/
    INSERT INTO [dbo].[MPY_MM_AceptacionPedidoDetalle]
    (
        [IdAceptacionPedido],
        [Cantidad],
        [Detalle],
        [CreadoPor],
        [Creado],
        [PrecioUnitario],
        [IdMoneda],
        [Unidad],
        [SAPNumber],
        [Partida],
        [DescripcionCorta],
        [DescripcionLarga]
    )
    select MPY_MM_AceptacionPedido.IdAceptacionPedido,
           CO_SAPGR.Quantity,
           CO_SAPGR.MaterialGroupDesc2,
           1,
           getdate(),
           CO_SAPGR.UnitPrice,
           CO_SAPPO.Currency,
           CO_SAPGR.UOM,
           CO_SAPGR.PO_SAPNumber,
           CO_SAPGR.POLineNumber,
           CO_SAPGR.MaterialGroupDesc2,
           CO_SAPGR.MaterialGroupDesc2
    from MPY_MM_AceptacionPedido (NOLOCK)
        inner join Adinco..CO_SAPGR (NOLOCK)
            on CO_SAPGR.PO_SAPNumber = @pPO_SAPNumber
               and CO_SAPGR.POLineNumber = @pPOLineNumber
               and MPY_MM_AceptacionPedido.DocumentDate = @pDocumentDate
               and LTRIM(RTRIM(UPPER(MPY_MM_AceptacionPedido.ReferenceNumber))) COLLATE DATABASE_DEFAULT = LTRIM(RTRIM(UPPER(CO_SAPGR.GRReferenceNumber)))
               and CO_SAPGR.Quantity >= 0
        inner join Adinco..CO_SAPPO (NOLOCK)
            on CO_SAPPO.SAPPONumber = CO_SAPGR.PO_SAPNumber
               and CO_SAPPO.ItemNumber = @pPOLineNumber
        LEFT JOIN MPY_MM_AceptacionPedidoDetalle (NOLOCK)
            ON MPY_MM_AceptacionPedido.IdAceptacionPedido = MPY_MM_AceptacionPedidoDetalle.IdAceptacionPedido
               AND CO_SAPGR.POLineNumber COLLATE DATABASE_DEFAULT = MPY_MM_AceptacionPedidoDetalle.Partida
    where MPY_MM_AceptacionPedido.IdAceptacionPedido = @pIdAceptacionPedido
          AND MPY_MM_AceptacionPedidoDetalle.Partida IS NULL

END







