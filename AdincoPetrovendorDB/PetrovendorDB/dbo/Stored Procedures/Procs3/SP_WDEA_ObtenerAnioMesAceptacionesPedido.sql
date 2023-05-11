USE [Petrovendor]
GO
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_WDEA_ObtenerAnioMesAceptacionesPedido'
)
    DROP PROCEDURE SP_WDEA_ObtenerAnioMesAceptacionesPedido;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 11/05/2023
-- Description:	obtener el primer y ultimo mes y a�o en que se tienen registros de las aceptaciones de WDEA
-- =============================================
CREATE PROCEDURE SP_WDEA_ObtenerAnioMesAceptacionesPedido
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@TipoConsulta NVARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET LANGUAGE SPANISH
	DECLARE @FECHA_ACTUAL DATETIME = GETDATE();
	DECLARE @ANIO_ACTUAL INT = YEAR(@FECHA_ACTUAL);
	DECLARE @FECHA_PRIMER_REGISTRO DATETIME;
	DECLARE @ANIO_PRIMER_REGISTRO INT;
	DECLARE @DIF INT;
	DECLARE @PRIMER_MES DATETIME = '20230101'--NO IMPORTA EL ANIO, ES PARA OBTENER EL PRIMER MES DEL A�O Y EL ULTIMO
	DECLARE @ULTIMO_MES DATETIME = '20231201'
	CREATE TABLE #CONTRATOS_USUARIO(
		IdContrato INT
	);

	CREATE TABLE #ANIOS(
		Anio INT
	);

	CREATE TABLE #MES(
		MesNumero INT,
		Mes NVARCHAR(100)
	);

	--SE CONSULTAN LOS MESES DEL A�O
	IF @TipoConsulta = 'MES'
	BEGIN

		--MESES DEL A�O
		INSERT INTO #MES
		SELECT
			(x.number + 1),
			DATENAME(MONTH, DATEADD(MONTH,x.number, @PRIMER_MES))
		FROM master.dbo.spt_values as x
		WHERE x.type = 'p'
		AND x.number <= DATEDIFF(MONTH, @PRIMER_MES, @ULTIMO_MES)

		SELECT
			MesNumero,
			Mes
		FROM #MES
		
	END

	--SE CONSULTAN LOS A�OS EN ACEPTACIONES
	IF @TipoConsulta = 'ANIO'
	BEGIN
		
		--SE OBTIENEN LOS CONTRATOS DEL USUARIO
		INSERT INTO #CONTRATOS_USUARIO(
			IdContrato
		)
		SELECT
			CC.IdContrato
		FROM Adinco..AP_PerfilUsuario AS PU (NOLOCK)
		INNER JOIN Adinco..AP_Usuario AS APU (NOLOCK)
			ON APU.UsuarioID = PU.UsuarioID
		INNER JOIN Adinco..AP_Perfil AS APP (NOLOCK)
			ON PU.PerfilID = APP.IdPerfil
		INNER JOIN Adinco..CO_Contrato AS CC (NOLOCK)
			ON APP.IdContrato = CC.IdContrato
		INNER JOIN Petrovendor.dbo.S_UsuarioProveedor uProv (NOLOCK)
			ON CC.IdContrato = uProv.IdContrato
		INNER JOIN Petrovendor.dbo.S_Proveedor prov (NOLOCK)
			ON uProv.IdProveedor = prov.IdProveedor
		INNER JOIN Petrovendor.dbo.S_Usuario u (NOLOCK)
			ON uProv.IdUsuario = u.IdUsuario
			AND	PU.UsuarioID = u.IdUsuarioADINCO
		WHERE
			( U.IdUsuario = @IdUsuario )
			 AND (	prov.IsEliminado = 0
			 OR	prov.IsEliminado IS NULL )
		GROUP BY CC.IdContrato;

		--EL PRIMER REGISTRO DE ACEPTACION DE LOS CONTRATOS DEL USUARIO
		SET @FECHA_PRIMER_REGISTRO = (SELECT TOP 1
											AP.Creado
										FROM MM_AceptacionPedido AS AP (NOLOCK)
										JOIN MM_Pedido AS P (NOLOCK)
											ON AP.IdPedido = P.IdPedido 
											AND AP.Activo = 1
										JOIN #CONTRATOS_USUARIO AS CC
												ON P.IdContrato = CC.IdContrato
										ORDER BY AP.Creado ASC)

		--SE OBTIENE EL A�O DEL PRIMER REGISTRO
		SET @ANIO_PRIMER_REGISTRO = YEAR(@FECHA_PRIMER_REGISTRO);

		--A�OS DE LAS ACEPTACIONES
		WHILE @ANIO_PRIMER_REGISTRO <= @ANIO_ACTUAL
		BEGIN

			INSERT INTO #ANIOS
			(
				Anio
			)
			VALUES
			(
				@ANIO_PRIMER_REGISTRO
			)

			SET @ANIO_PRIMER_REGISTRO = @ANIO_PRIMER_REGISTRO + 1;

		END

		SELECT
			Anio
		FROM #ANIOS

	END

END
GO
