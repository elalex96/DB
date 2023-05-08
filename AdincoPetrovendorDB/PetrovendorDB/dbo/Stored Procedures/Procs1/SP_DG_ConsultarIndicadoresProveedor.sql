-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- =============================================
-- Author:		<Abel Rivera>
-- Modificado date: <08/01/2018>
-- Description:	<Se agrego al select la cantidad de estrellas del provedor seleccionado>

-- Author:		<Abel Rivera>
-- Modificado date: <28/05/2018>
-- Description:	<Se cambio de donde se obtenian los datos de los materiales , de materialesVentasProveedor a material>
-- =============================================

	CREATE PROCEDURE [dbo].[SP_DG_ConsultarIndicadoresProveedor]
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON; 

	--DECLARE @MATERIALESVENTA INT = (SELECT COUNT(*) AS MATERIALESVENTA FROM MM_MaterialesVentaProveedor WHERE IdProveedor = @IdProveedor AND IsActivo = 1)
	DECLARE @MATERIALESVENTA INT = (SELECT COUNT(*) AS MATERIALESVENTA FROM dbo.MM_Material WHERE IdProveedor = @IdProveedor AND Activo = 1)
  --   DECLARE @ESTRELLAS INT
	 --EXEC dbo.SP_EP_ObtenerEstrellas @IdProveedor,@ESTRELLAS OUTPUT
	 

	
	DECLARE @COTIZACIONESHECHAS INT = (SELECT 
		COUNT(*)
				--PO.IdPeticionOferta, 
			 --  PO.CreadoEl,  
			 --  O.FechaFinalizacion AS FechaLimite,
			 --  RazonSocial +' '+ RegimenCapital AS RazonSocial
			   --E.Nombre AS Estatus, 
			   --ISNULL(Cotizado,'false') AS Cotizado
		FROM MM_PeticionOferta AS PO
			INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IDSolicitudPedido
			INNER JOIN TA_Operacion  AS O ON O.IdDocumento = PO.IdSolicitudPedido 
			--INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
			INNER JOIN S_Proveedor AS P ON P.IdProveedor = SP.IdProveedor
			--INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			--INNER JOIN TA_Estatus AS E ON E.IdEstatus = ISNULL(PO.IdEstatus,1)
		WHERE PO.IdSubcontratista = @IdProveedor 
			AND O.IdTipoOperacion = 6
			AND PO.Cotizado = 1)	
			
	SELECT @MATERIALESVENTA AS MATERIALESVENTA, @COTIZACIONESHECHAS AS COTIZACIONESHECHAS,dbo.ObtenerEstrellasModificado(@IdProveedor) AS CalificacionEstrellas
END 
