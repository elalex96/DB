-- =============================================
-- Author:		<Alexander G>
-- Create date: <07/12/2017>
-- Description:	<SP para consultar los datos del encabezado del proveedor y la operadora deacuerdo a un pedido>
-- =============================================
-- Author:		DANIEL AC 
-- Update date: 07/02/2018
-- Description:	Removi condicion de IdTipoPedido=2
-- =============================================
-- Author:		Alexander Gomez 
-- Update date: 12/03/2018
-- Description:	Se removio el campo de nombre de vialidad
-- =============================================
-- Author:		Jose Roman
-- Update date: 24/08/2018
-- Description:	Se concatenan los Centros de Costos de cada detalle
-- Update date: 03/09/2018
-- Description:	Se concatenan la primera linea de presupuesto que se usa en un pedido
-- Update date: 29/10/2018
-- Description:	Se agregan los apellidos del contacto del proveedor
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 16/08/2019
-- Description:	Se agrego el nombre del presupuesto
-- =============================================

CREATE PROCEDURE [dbo].[SP_RPT_OCM_CabeceraOrdenCompra] --1656
	-- Add the parameters for the stored procedure here  
	@IdPedido INT,
		/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT=NULL,
    @IdUsuario     INT=NULL,
    @FechaRegistro DATETIME=NULL
	/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CENTROSDECOSTO NVARCHAR(MAX)
	DECLARE	@LineasPresupuesto TABLE(IdLineaPresupuesto INT, IdActividad NVARCHAR(max), Actividad NVARCHAR(max), IdSubActividad NVARCHAR(max), SubActividad NVARCHAR(max), IdTarea NVARCHAR(max), Tarea NVARCHAR(MAX), IdServicio NVARCHAR(max), Servicio NVARCHAR(MAX), IdPresupuesto NVARCHAR(MAX), NombrePresupuesto NVARCHAR(MAX))
	DECLARE @LineaPresupuesto NVARCHAR(max)

	SELECT @CENTROSDECOSTO =  COALESCE(@CENTROSDECOSTO + ', ', '') + cc.CentroCosto
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN dbo.MM_Pedido AS P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	LEFT JOIN dbo.CC_CentroCosto AS CC ON CC.IdCentroCosto = SPDLP.IdCentroCosto
	WHERE P.IdPedido = @IdPedido
	GROUP BY CC.CentroCosto

	INSERT INTO @LineasPresupuesto
	(
	    IdLineaPresupuesto,
	    IdActividad,
	    Actividad,
	    IdSubActividad,
	    SubActividad,
	    IdTarea,
	    Tarea,
	    IdServicio,
	    Servicio,
		IdPresupuesto,
		NombrePresupuesto
	)
	SELECT TOP 1 lpm.IdLineaPresupuestoMes, 
		a.id_Actividad, 
		a.DescripcionActividadPetrolera,
		sb.[id_Sub-actividad],
		sb.SubactividadPetrolera,
		tp.id_Tarea,
		tp.TareaPetrolera,
		s.IdServicio,
		s.NombreServicio,
		PRS.IdPresupuesto,
		PRS.Nombre AS NombrePresupuesto
	FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN dbo.MM_Pedido AS P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
	LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH a ON a.IdActividadPetrolera = lpm.IdActividadPetrolera
	LEFT JOIN adinco.dbo.CO_SubactividadPetrolera sb ON sb.IdSubactividadPetrolera = lpm.IdSubactividadPetrolera
	LEFT JOIN Adinco.dbo.CO_TareaPetrolera tp ON tp.IdTareaPetrolera = lpm.IdTareaPetrolera
	LEFT JOIN Adinco.dbo.CO_Servicio s ON s.IdServicio = lpm.IdServicio
	LEFT JOIN Adinco.dbo.CO_Presupuesto AS PRS ON PRS.IdPresupuesto = lpm.IdPresupuesto
	WHERE P.IdPedido = @IdPedido

	SELECT @LineaPresupuesto = CONCAT(' Presupuesto: ', NombrePresupuesto,' | ' ,IdActividad, ' | ', Actividad, ' | ', IdSubActividad, ' | ', SubActividad, ' | ', IdTarea, ' | ', Tarea, ' | ', IdServicio, ' | ', Servicio)
	FROM @LineasPresupuesto

	SELECT
	--DATOS DE LA OPERADORA--
	IMO.ImagenProveedor AS LOGOOPERADORA, 
	OPERADOR.RazonSocial AS OPERADORA,
	CONCAT('Calle: ',ISNULL(DO.Calle,''), ' N°Ext: ',ISNULL(DO.NoExterior,''), ' N°Int: ',ISNULL(DO.NoInterior,''), ' Col.', ISNULL(DO.Colonia,''), ' C.P. ',ISNULL(DO.CodigoPostal,''),' ',ISNULL(DO.Municipio,''),' ',ISNULL(DO.Estado,''),' ',ISNULL(DO.Pais,'')) AS DOMICILIOOPERADORA,
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
	U.Nombre AS SOLICITANTE,
	@CENTROSDECOSTO AS CENTROSDECOSTOS,
	--DATOS DEL PROVEEDOR--
	IMP.ImagenProveedor  AS LOGOPROVEEDOR,
	PROVEDOR.RazonSocial AS PROVEEDOR,
	CONCAT(' Calle: ',ISNULL(DP.Calle,''), '  N°Ext: ',ISNULL(DP.NoExterior,''), '  N°Int: ', ISNULL(DP.NoInterior,''), '  Col.', ISNULL(DP.Colonia,''), ' C.P. ',ISNULL(DP.CodigoPostal,''),'  ',ISNULL(DP.Municipio,''),' ',ISNULL(DP.Estado,''),' ',ISNULL(DP.Pais,'')) AS DOMICILIOPROVEEDOR,
	PROVEDOR.RFC AS RFCPROVEEDOR,
	PROVEDOR.Telefono AS TELEFONOPROVEEDOR,
	(CPA.Nombres + ', ' + CPA.Apellidos) AS NOMBRECONTACTOPROVEEDOR,
	ISNULL(CPA.Email, '') AS CORREOCONTACTOPROVEEDOR,
	ISNULL(@LineaPresupuesto, '') AS LINEAPRESUPUESTO
	FROM dbo.MM_Pedido AS P
	LEFT JOIN dbo.S_Proveedor AS PROVEDOR ON PROVEDOR.IdProveedor = P.IdSubcontratista
	LEFT JOIN dbo.S_Proveedor AS OPERADOR ON OPERADOR.IdProveedor = P.IdProveedorCompras
	LEFT JOIN dbo.S_ImagenPerfil AS IMO ON IMO.IdProveedor = OPERADOR.IdProveedor
	LEFT JOIN dbo.S_ImagenPerfil AS IMP ON IMP.IdProveedor = PROVEDOR.IdProveedor
	LEFT JOIN dbo.DG_Domicilio AS DO ON DO.IdProveedor = P.IdProveedorCompras AND DO.IdTipoDomicilio = 1 AND DO.Activo=1
	LEFT JOIN dbo.DG_Domicilio AS DP ON DP.IdProveedor = P.IdSubcontratista AND DP.IdTipoDomicilio = 1 AND DP.Activo=1
	LEFT JOIN dbo.S_Usuario AS SU ON SU.IdUsuario = P.CreadoPor
	LEFT JOIN Adinco.dbo.CO_Contrato AS ACONTRATOOPE ON ACONTRATOOPE.IdContrato = P.IdContrato
	LEFT JOIN Adinco.dbo.CO_AreaContractual AS AAREAOPE ON AAREAOPE.IdAreaContractual = ACONTRATOOPE.IdAreaContractual
	LEFT JOIN dbo.S_Contacto_PA AS CPA ON CPA.IdProveedor = P.IdSubcontratista AND CPA.IdTipoContacto = 1 AND CPA.IsPredeterminado = 1
	LEFT JOIN dbo.TA_Operacion TAO  ON P.IdSolicitudPedido = TAO.IdDocumento AND TAO.IdTipoOperacion = 2 
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras	
	LEFT JOIN dbo.S_Usuario U ON TAO.IdAsignador = U.IdUsuario
	WHERE 
		P.IdPedido = @IdPedido

END
