-- =============================================
-- Author:		Miguel Gomez
-- Create date: 21-09-2018
-- Description:	Crea aceptacion de servicio basado en SES o GR
-- =============================================
CREATE procedure [dbo].[sp_MPY_SESGRtoAceptacion]
--sp_MPY_SESGRtoAceptacion 1,1000002094, 1 , 1
	-- Add the parameters for the stored procedure here
@SESGR      INT           = 0,
@IdSESGR    NVARCHAR(MAX),
@IdUsuario  INT,
@Idcontrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             IF @SESGR = 1
                 BEGIN
                     INSERT INTO [dbo].[MPY_MM_AceptacionPedido]
([IdProveedor],
 [IdPedido],
 [Comentario],
 [NombreUsuarioEntrega],
 [Activo],
 [Creado],
 [IdDomicilioEntrega],
 [CreadorPor],
 [IdSubContratista],
 [IdContrato],
 [Version],
 [CostObject],
 [MaterialGroup],
 [MaterialgroupDesc2],
 [Qty],
 [Price],
 [costobject2],
 [ServiceGroup],
 [SAPNumber],
 [PaisSAP],
 [Contacto],
 [CorreoContacto],
 [VendorsName],
 [VendorAddress],
 [ServiceLineNumber],
 [ShortText],
 [ParentLineUOM],
 [ServiceShortText],
 [ServicesUOM]
)
                            SELECT distinct po.SAPVendorNumber,
                                   po.SAPPONumber,
                                   '' AS comentario,
                                   NULL AS NombreUsuario,
                                   1 AS Activo,
                                   CURRENT_TIMESTAMP AS creado,
                                   Deliveryaddress AS domicilio,
                                   1 AS creadopor, --'@IdUsuario' AS CreadorPor,
                                   V.TaxID AS IdSubcontratista,
                                   '@IdContrato' AS IdContrato,
                                   po.VersionNumber,
                                   s.CostObject,
                                   '',--s.MaterialGroup,
                                   s.MaterialGroupDesc2,
                                   s.Quantity,
                                   s.UnitPrice,
                                   po.CostObject2,
                                   po.ServiceGroup,
                                   NULL AS sapnumber,
                                   v.Country,
                                   v.ContactName,
                                   v.ContactEmail,
                                   v.VendorName,
                                   v.Address,
                                   po.ServiceLineNumber,
                                   po.ShortText,
                                   po.ParentLineUOM,
                                   po.ServiceShortText,
              --'MG',--po.ServiceShortText,
                                   po.ServicesUOM
                            FROM adinco..CO_SAPPO PO
                                 JOIN adinco..co_sapses S ON S.PO_SAPNumer = PO.SAPPONumber
                                 JOIN adinco..CO_SAPVendor V ON V.VendorIDSAP = po.SAPVendorNumber
                            WHERE s.SESNumber = @IdSESGR;
                     SELECT @@IDENTITY AS ID;
                 END;
                 ELSE
                 BEGIN
                     INSERT INTO [dbo].[MPY_MM_AceptacionPedido]
([IdProveedor],
 [IdPedido],
 [Comentario],
 [NombreUsuarioEntrega],
 [Activo],
 [Creado],
 [IdDomicilioEntrega],
 [CreadorPor],
 [IdSubContratista],
 [IdContrato],
 [Version],
 [CostObject],
 [MaterialGroup],
 [MaterialgroupDesc2],
 [Qty],
 [Price],
 [costobject2],
 [ServiceGroup],
 [SAPNumber],
 [PaisSAP],
 [Contacto],
 [CorreoContacto],
 [VendorsName],
 [VendorAddress],
 [ServiceLineNumber],
 [ShortText],
 [ParentLineUOM],
 [ServiceShortText],
 [ServicesUOM]
)
                            SELECT distinct po.SAPVendorNumber,
                                   po.SAPPONumber,
                                   '' AS comentario,
                                   NULL AS NombreUsuario,
                                   1 AS Activo,
                                   CURRENT_TIMESTAMP AS creado,
                                   Deliveryaddress AS domicilio,
                                   1 AS creadopor, --'@IdUsuario' AS CreadorPor,
                                   V.TaxID AS IdSubcontratista,
                                   '@IdContrato' AS IdContrato,
                                   po.VersionNumber,
                                   s.CostObject,
                                   s.MaterialGroup,
                                   s.MaterialGroupDesc2,
                                   s.Quantity,
                                   s.UnitPrice,
                                   po.CostObject2,
                                   po.ServiceGroup,
                                   NULL AS sapnumber,
                                   v.Country,
                                   v.ContactName,
                                   v.ContactEmail,
                                   v.VendorName,
                                   v.Address,
                                   po.ServiceLineNumber,
                                   po.ShortText,
                                   po.ParentLineUOM,
                                   po.ServiceShortText,
              --'MG',--po.ServiceShortText,
                                   po.ServicesUOM
                            FROM adinco..CO_SAPPO PO
                                 JOIN adinco..co_sapses S ON S.PO_SAPNumer = PO.SAPPONumber
                                 JOIN adinco..CO_SAPVendor V ON V.VendorIDSAP = po.SAPVendorNumber
                            WHERE s.SESNumber = @IdSESGR;
                     SELECT @@IDENTITY AS ID;
                 END;
         END;
