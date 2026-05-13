USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_RPT_OCM_CabeceraOrdenCompra'
)
    DROP PROCEDURE SP_RPT_OCM_CabeceraOrdenCompra;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander G>
-- Create date: <17/06/2021>
-- Description:	<SP para consultar los datos del encabezado del proveedor y la operadora deacuerdo a un pedido>
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/10/2023
-- Description:	se agregan estandares de desarrollo
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_OCM_CabeceraOrdenCompra] --17493
	-- Add the parameters for the stored procedure here  
	@IdPedido INT,
    @IdContrato    INT=NULL,
    @IdUsuario     INT=NULL,
    @FechaRegistro DATETIME=NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CENTROSDECOSTO NVARCHAR(MAX)
	--DECLARE	@LineasPresupuesto TABLE(IdLineaPresupuesto INT, IdActividad NVARCHAR(max), Actividad NVARCHAR(max), IdSubActividad NVARCHAR(max), SubActividad NVARCHAR(max), IdTarea NVARCHAR(max), Tarea NVARCHAR(MAX), IdServicio NVARCHAR(max), Servicio NVARCHAR(MAX), IdPresupuesto NVARCHAR(MAX), NombrePresupuesto NVARCHAR(MAX))
	DECLARE @LineaPresupuesto NVARCHAR(max)

	SELECT @CENTROSDECOSTO =  COALESCE(@CENTROSDECOSTO + ', ', '') + cc.CentroCosto
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
		ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido 
	LEFT JOIN dbo.MM_Pedido AS P (NOLOCK)
		ON SP.IdSolicitudPedido = P.IdSolicitudPedido  
	LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP (NOLOCK) 
		ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle 
	LEFT JOIN dbo.CC_CentroCosto AS CC (NOLOCK)
		ON SPDLP.IdCentroCosto= CC.IdCentroCosto 
	WHERE P.IdPedido = @IdPedido
	GROUP BY CC.CentroCosto

	SELECT TOP 1 
		@LineaPresupuesto = 
		CONCAT(
		   ISNULL('Instalación: ' + INS.NombreInstalacion  COLLATE Modern_Spanish_CI_AS,''), 

		   ISNULL(' |Linea de presupuesto: '+dbo.Fn_RetornarMesProgramadoActividadConcat(lpm.IdLineaPresupuestoMes),''))
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
		ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido 
	LEFT JOIN dbo.MM_Pedido AS P (NOLOCK)
		ON SP.IdSolicitudPedido = P.IdSolicitudPedido 
	LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP (NOLOCK)
		ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle 
	LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK)
		ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
	LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH a (NOLOCK)
		ON lpm.IdActividadPetrolera =  a.IdActividadPetrolera
	LEFT JOIN adinco.dbo.CO_SubactividadPetrolera sb (NOLOCK)
		ON lpm.IdSubactividadPetrolera = sb.IdSubactividadPetrolera 
	LEFT JOIN Adinco.dbo.CO_TareaPetrolera tp (NOLOCK)
		ON lpm.IdTareaPetrolera = tp.IdTareaPetrolera 
	LEFT JOIN Adinco.dbo.CO_Servicio s (NOLOCK)
		ON  lpm.IdServicio = s.IdServicio
	LEFT JOIN Adinco.dbo.CO_Presupuesto AS PRS (NOLOCK)
		ON lpm.IdPresupuesto = PRS.IdPresupuesto  
	LEFT JOIN Adinco.dbo.CO_Instalacion ins (NOLOCK)
		ON lpm.IdInstalacion= ins.IdInstalacion 
	WHERE P.IdPedido = @IdPedido

	SELECT
	--DATOS DE LA OPERADORA--
	IMO.ImagenProveedor AS LOGOOPERADORA, 
	OPERADOR.RazonSocial AS OPERADORA,
	CONCAT('Calle: ',ISNULL(DO.Calle,''), ' NºExt: ',ISNULL(DO.NoExterior,''), ' NºInt: ',ISNULL(DO.NoInterior,''), ' Col.', ISNULL(DO.Colonia,''), ' C.P. ',ISNULL(DO.CodigoPostal,''),' ',ISNULL(DO.Municipio,''),' ',ISNULL(DO.Estado,''),' ',ISNULL(DO.Pais,'')) AS DOMICILIOOPERADORA,
	OPERADOR.RFC AS RFCOPERADORA,
	SU.Nombre AS NOMBRECONTACTOOPE,
	SU.Correo AS CORREOCONTACTOOPE,
	OPERADOR.Telefono AS TELEFONOOPERADOR,
	--ESPECIFICACIONES DE LA OPERADORA--
	PG.IdPedido AS FOLIO,
	P.CreadoEl AS FECHA,
	ACONTRATOOPE.NumeroContrato AS NUMEROCONTRATO,
	AAREAOPE.NombreAreaContractual AS AREACONTRACTUAL,
	TAO.IdDocumento AS REQUISICION,
	ISNULL(US.Nombre,'N/A') AS SOLICITANTE,
	@CENTROSDECOSTO AS CENTROSDECOSTOS,
	--DATOS DEL PROVEEDOR--
	IMP.ImagenProveedor  AS LOGOPROVEEDOR,
	PROVEDOR.RazonSocial AS PROVEEDOR,
	CONCAT(' Calle: ',ISNULL(DP.Calle,''), '  NºExt: ',ISNULL(DP.NoExterior,''), '  NºInt: ', ISNULL(DP.NoInterior,''), '  Col.', ISNULL(DP.Colonia,''), ' C.P. ',ISNULL(DP.CodigoPostal,''),'  ',ISNULL(DP.Municipio,''),' ',ISNULL(DP.Estado,''),' ',ISNULL(DP.Pais,'')) AS DOMICILIOPROVEEDOR,
	PROVEDOR.RFC AS RFCPROVEEDOR,
	PROVEDOR.Telefono AS TELEFONOPROVEEDOR,
	(CPA.Nombres + ', ' + CPA.Apellidos) AS NOMBRECONTACTOPROVEEDOR,
	ISNULL(CPA.Email, '') AS CORREOCONTACTOPROVEEDOR,
	ISNULL(@LineaPresupuesto, '') AS LINEAPRESUPUESTO,
	U.Nombre  AS CREADOPOR
	FROM dbo.MM_Pedido AS P (NOLOCK)
	LEFT JOIN dbo.S_Proveedor AS PROVEDOR (NOLOCK)
		ON P.IdSubcontratista = PROVEDOR.IdProveedor 
	LEFT JOIN dbo.S_Proveedor AS OPERADOR (NOLOCK)
		ON  P.IdProveedorCompras =OPERADOR.IdProveedor
	LEFT JOIN dbo.S_ImagenPerfil AS IMO (NOLOCK)
		ON  OPERADOR.IdProveedor = IMO.IdProveedor
	LEFT JOIN dbo.S_ImagenPerfil AS IMP (NOLOCK)
		ON PROVEDOR.IdProveedor = IMP.IdProveedor 
	LEFT JOIN dbo.DG_Domicilio AS DO (NOLOCK)
		ON P.IdProveedorCompras  = DO.IdProveedor 
		AND DO.IdTipoDomicilio = 1 AND DO.Activo=1
	LEFT JOIN dbo.DG_Domicilio AS DP (NOLOCK)
		ON P.IdSubcontratista  = DP.IdProveedor 
		AND DP.IdTipoDomicilio = 1 AND DP.Activo=1
	LEFT JOIN MM_SolicitudPedido AS SP (NOLOCK)
		ON P.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN S_Usuario AS US (NOLOCK)
		ON SP.Solicitante = US.IdUsuario			
	LEFT JOIN dbo.S_Usuario AS SU (NOLOCK)
		ON  P.CreadoPor = SU.IdUsuario
	LEFT JOIN Adinco.dbo.CO_Contrato AS ACONTRATOOPE (NOLOCK)
		ON  P.IdContrato = ACONTRATOOPE.IdContrato 
	LEFT JOIN Adinco.dbo.CO_AreaContractual AS AAREAOPE (NOLOCK)
		ON  ACONTRATOOPE.IdAreaContractual = AAREAOPE.IdAreaContractual 
	LEFT JOIN dbo.S_Contacto_PA AS CPA (NOLOCK)
		ON  P.IdSubcontratista = CPA.IdProveedor 
		AND CPA.IdTipoContacto = 1 
		AND CPA.IsPredeterminado = 1
	LEFT JOIN dbo.TA_Operacion TAO  (NOLOCK)
		ON P.IdSolicitudPedido = TAO.IdDocumento 
		AND TAO.IdTipoOperacion = 2 
	INNER JOIN dbo.MM_Pedidos AS PG (NOLOCK)
		ON P.IdPedido = PG.IdIdentificador 
		AND PG.IdProveedorCliente = P.IdProveedorCompras
		AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
	LEFT JOIN dbo.S_Usuario U 
		ON TAO.IdAsignador = U.IdUsuario
	WHERE 
		P.IdPedido = @IdPedido

END