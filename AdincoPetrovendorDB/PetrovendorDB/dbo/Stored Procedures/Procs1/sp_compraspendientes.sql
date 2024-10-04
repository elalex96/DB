USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_compraspendientes'
)
    DROP PROCEDURE sp_compraspendientes;   
	
GO
/****** Object:  StoredProcedure [dbo].[SP_ENT_EnviarCorreoAlerta]    Script Date: 19/06/2024 11:20:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Modificacion:<Jose Roman>
-- Create date: <27-03-2018>
-- Description:	<Se agregan parametros de contrato, la moneda y filtro de contrato>
-- =============================================
-- Modificacion:		Jose Roman
-- Create date: 15-08-2018
-- Description:	Se filtran las aprobaciones de tipo serial, donde los aprobadores con numero de secuencia menos aun no han aprobado la operacion			
-- =============================================
-- Modificacion:		Alexander Gomez
-- Create date: 30-01-2019
-- Description:	Se filtran las aprobaciones por proveedor	
-- =============================================
-- Author:		Daniel AC
-- Update date: 03/10/2024
-- Description: Se agrega mejoras de estándares issue #2825
-- =============================================
CREATE PROCEDURE [dbo].[sp_compraspendientes] 
	@IdUsuario INT, 
	@IdProveedor INT,
    @IdContrato    INT = null,
    @FechaRegistro DATETIME = null
AS
BEGIN
	
	DECLARE @FlujoSerial TABLE(IdOperacion INT, NoSecuencia INT)
	DECLARE @FlujosNoAprobados TABLE(IdOperacion INT) 
	DECLARE @TareasUsuario TABLE(
	IdOperacion INT,
	Descripcion NVARCHAR(MAX),
	IdDocumento INT,
	IdAsignador INT,
	IdAprobador INT,
	IdTipoFlujo INT,
	NoSecuencia INT,
	IdTarea INT,
	IdVigencia INT,
	FechaRegistro DATETIME)

	INSERT INTO @TareasUsuario(
		IdOperacion,
		Descripcion,
		IdDocumento,
		IdAsignador,
		IdAprobador,
		IdTipoFlujo,
		NoSecuencia,
		IdTarea,
		FechaRegistro
	)
	SELECT 
	O.IdOperacion,
	O.Descripcion,
	O.IdDocumento,
	O.IdAsignador,
	TA.IdAprobador,
	FT.IdTipoFlujo,
	TA.NoSecuencia,
	TA.IdTarea,
	O.FechaRegistro
	FROM TA_Operacion O  (NOLOCK)
	JOIN dbo.TA_Tarea TA   (NOLOCK)
	 ON O.IdOperacion = TA.IdOperacion 
	    AND O.IdTipoOperacion = 14 --> CTE APROBACIÓN DE  COMPRA DIRECTA	
		AND O.IdEstatusOperacion = 1 --> CTE OPERACIÓN EN ESTATUS EN APROBACIÓN		
		AND TA.IdEstatus = 1 --> CTE APROBACIÓN TAREA EN APROBACIÓN 
		AND TA.IdAprobador = @IdUsuario	
		AND O.IdProveedor = @IdProveedor 
		AND ISNULL(O.IdEstatusEliminado,0) <> 1  -->CTE QUE NO ESTEN ELIMINADAS
	JOIN dbo.TA_FlujoTarea FT  (NOLOCK)
			ON o.IdFlujoTarea = ft.IdFlujoTarea 
	GROUP BY 
	O.IdOperacion,
	O.Descripcion,
	O.IdDocumento,
	O.IdAsignador,
	FT.IdTipoFlujo,
	TA.NoSecuencia,
	TA.IdAprobador,
	TA.IdTarea,
	O.FechaRegistro

	--SE OBTIENEN LOS FLUJOS DE TIPO SERIAL QUE EL APROBADOR AUN NO HA APROBADO
	INSERT INTO @FlujoSerial
	(
		IdOperacion, NoSecuencia
	)
	SELECT OU.IdOperacion, OU.NoSecuencia
	FROM @TareasUsuario OU 
	WHERE OU.IdTipoFlujo = 1 -- CTE SOLO APROBACIONES DE TIPO SERIAL 		
		AND OU.NoSecuencia > 1  -- DONDE EL APROBADOR NO SEA EL PRIMER APROBADOR
	GROUP BY  OU.IdOperacion, OU.NoSecuencia

	-- DE LOS FLUJOS AUN NO APROBADOS SE OBTIENEN LOS QUE AUN NO CUENTEN CON UNA APROBACION PREVIA Y POR LO TANTO SERAN EXCLUIDOS DE LA CONSULTA
	INSERT INTO @FlujosNoAprobados
	(
		IdOperacion
	)
	SELECT o.IdOperacion
	FROM @TareasUsuario OU 
		JOIN dbo.TA_Operacion O(NOLOCK)
			ON OU.IdOperacion = O.IdOperacion		
		JOIN dbo.TA_Tarea T (NOLOCK)
			ON O.IdOperacion  = T.IdOperacion 
			AND T.Activo = 1	-- QUE ESTEN ACTIVOS
		JOIN @FlujoSerial TB 
			ON O.IdOperacion  = TB.IdOperacion 
			AND T.NoSecuencia = (TB.NoSecuencia - 1)
	WHERE T.IdAprobador <> @IdUsuario -- SE EXCLUYE EL USUARIO APROBADOR ACTUAL
		AND T.IdEstatus <> 2 

	-- REMOVER APROBACIONES SERIALES QUE AUN NO HA SIDO APROBADAS POR ALGUN USUARIO CON SECUENCIA ANTERIOR
	DELETE TU
	FROM @TareasUsuario TU
	JOIN  @FlujosNoAprobados FNA
		ON TU.IdOperacion = FNA.IdOperacion

	SELECT  R.IdRegistro,
			TAU.IdOperacion AS Operacion,
			TAU.Descripcion AS Descripcion,
			TAU.IdDocumento AS Compra,
			TAU.IdAsignador AS creado,
			U.IdUsuario AS num_user,
			1 AS tpuser,
			DATEADD(DAY, V.DiaVencimiento, TAU.FechaRegistro) AS Finalizacion,
			PG.IdPedido AS IdPedidoGeneral,
			F.Emisor,
			F.FechaTimbrado,
			((F.MontoConIva * 100)/100) AS Monto,
			I.NombreInstalacion AS Instalacion,
			F.Moneda,
			TAU.IdTarea	
	FROM @TareasUsuario TAU  		
	 JOIN S_Usuario U   (NOLOCK)
		ON TAU.IdAprobador = U.IdUsuario
	 LEFT JOIN dbo.TA_Vencimiento V   (NOLOCK)
		ON  TAU.IdVigencia = V.IdVencimiento 
	 LEFT JOIN dbo.MM_Pedidos PG   (NOLOCK)
		ON TAU.IdDocumento  = PG.IdIdentificador
		AND PG.IdProveedorCliente   = @IdProveedor
		AND PG.IdTipoPedido = 1 --> CTE PEDIDO DE COMPRA DIRECTA		
	 LEFT JOIN dbo.FI_Factura F   (NOLOCK)
				ON TAU.IdDocumento  = F.IdFactura      
	 LEFT JOIN dbo.CO_Registro R   (NOLOCK)
				ON F.IdFactura = R.IdFactura 
	 LEFT JOIN Adinco.dbo.CO_Instalacion I   (NOLOCK)
				ON  R.IdInstalacion = I.IdInstalacion 
	 LEFT JOIN dbo.S_UsuarioProveedor UP   (NOLOCK)
				ON U.IdUsuario = UP.IdUsuario 
	WHERE UP.IdProveedor = @IdProveedor
		AND F.IdContrato = UP.idContrato
	GROUP BY R.IdRegistro,
			TAU.IdOperacion,
			TAU.Descripcion,
			TAU.IdDocumento,
			TAU.IdAsignador,
			U.IdUsuario,
			V.DiaVencimiento,
			TAU.FechaRegistro,
			PG.IdPedido,
			F.Emisor,
			F.FechaTimbrado,
			F.MontoConIva,
			I.NombreInstalacion,
			F.Moneda,
			TAU.IdTarea
	ORDER BY TAU.IdOperacion DESC;
END;