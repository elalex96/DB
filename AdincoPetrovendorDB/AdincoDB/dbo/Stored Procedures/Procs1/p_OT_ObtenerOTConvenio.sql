USE [Adinco]
GO
DROP PROCEDURE IF EXISTS p_OT_ObtenerOTConvenio
/****** Object:  StoredProcedure [dbo].[p_OT_ObtenerOTConvenio]    Script Date: 07/04/2025 05:12:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Update date: 06-10-2020
-- Description: Se agrego filtro por contrato
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 08-04-2025
-- Description: Se usa p_OT_ConsultaOTSolicitud para que la informacion este homologada con adinco 
-- =============================================
CREATE PROC [dbo].[p_OT_ObtenerOTConvenio]
    @pUsuario VARCHAR(250),
    @pAprobada BIT,
    @IdContrato INT
AS
BEGIN

SET NOCOUNT ON;

	IF @pAprobada = 0
	BEGIN

		DECLARE @FECHA_HASTA DATETIME = GETDATE(),
			@FECHA_DESDE DATETIME = DATEADD(YEAR, -1, GETDATE()),
			@IdUsuario INT = (SELECT TOP 1 UsuarioID 
								FROM AP_Usuario (NOLOCK)
							WHERE Usuario = RTRIM(@pUsuario) AND IsActivo = 1),
			@IdContratista INT = (SELECT IdContratista 
									FROM CO_Contrato (NOLOCK)
									WHERE IdContrato = @IdContrato);

		CREATE TABLE #OT_SolicitudDelContrato
		(
			IdOTSolicitud       INT PRIMARY KEY,
			IdSubContrato       int,
			Folio               varchar(150),
			FechaInicio DATETIME,
			FechaFin DATETIME,
			PlazoEjecucion	INT,
			CreadoPor INT,
			CreadoEl DATETIME,
			ModificadoPor INT,
			ModificadoEl	DATETIME,
			IsActivo            bit,
			isEliminado bit,
			IdPresupuesto INT,
			Objeto	varchar(1000),
			IdOTEstatus         INT,
			FechaFinExtendida	DATETIME,
			IdOTEstatusAnt INT,
			NombrePresupuesto varchar(300),
			PuedeEstimar bit,
			Excedida bit,
			AFinanciero INT,
			TotalOT FLOAT,
			Moneda varchar(100),
			Subcontratista varchar(300),
			CentroCosto varchar(300),
			SAPPR varchar(50)
		);

		INSERT INTO #OT_SolicitudDelContrato
		EXEC p_OT_ConsultaOTSolicitud @pIdContratista=@IdContratista,
									@pIdContrato=@IdContrato,
									@pPendientes=0,
									@pAprobadas=0,
									@pRechazadas=0,
									@pExcedidas=0,
									@pRequiereConvenio=1,
									@pTodas=0,
									@pIdSubcontrato=0,
									@pUsuarioId=@IdUsuario,
									@Desde=@FECHA_DESDE,
									@Hasta=@FECHA_HASTA;

		SELECT 
			OT.IdOTSolicitud,
			OT.IdSubContrato,
			OT.Folio,
			OT.FechaInicio,
			OT.FechaFin,
			OT.PlazoEjecucion,
			OT.CreadoPor,
			OT.CreadoEl,
			OT.ModificadoPor,
			OT.ModificadoEl,
			OT.IsActivo,
			OT.isEliminado,
			OT.IdPresupuesto,
			OT.Objeto,
			OT.IdOTEstatus,
			OT.FechaFinExtendida,
			OT.IdOTEstatusAnt,
			OT.NombrePresupuesto,
			con.IdOTConvenio,
			OT.Moneda
		FROM #OT_SolicitudDelContrato AS OT
		INNER JOIN OT_Convenio con  (NOLOCK)
				ON OT.IdOTSolicitud = con.IdOTSolicitud ;

	END
	ELSE
	BEGIN
		
			SELECT sol.IdOTSolicitud,
			   sol.IdSubContrato,
			   sol.Folio,
			   sol.FechaInicio,
			   sol.FechaFin,
			   sol.PlazoEjecucion,
			   sol.CreadoPor,
			   sol.CreadoEl,
			   sol.ModificadoPor,
			   sol.ModificadoEl,
			   sol.IsActivo,
			   sol.IsEliminado,
			   sol.IdPresupuesto,
			   sol.Objeto,
			   sol.IdOTEstatus,
			   sol.FechaFinExtendida,
			   sol.IdOTEstatusAnt,
			   NombrePresupuesto = pre.Nombre,
			   subC.IdSubContrato,
			   con.IdOTConvenio,
			   Moneda = ISNULL(TipoMonedaCorto, 'NO ESPECIFICADO')
		FROM [OT_Solicitud] sol (NOLOCK)
			INNER JOIN CO_Presupuesto pre  (NOLOCK)
				ON sol.IdPresupuesto = pre.IdPresupuesto 
			INNER JOIN dbo.SC_SubContrato subC  (NOLOCK)
				ON sol.IdSubContrato = subC.IdSubContrato 
			INNER JOIN dbo.PV_Subcontratista SUB  (NOLOCK)
				ON subC.IdSubContratista = SUB.IdSubcontratista 
			INNER JOIN Petrovendor.dbo.S_Proveedor prov  (NOLOCK)
				ON SUB.RFC COLLATE DATABASE_DEFAULT = prov.RFC COLLATE DATABASE_DEFAULT 
			INNER JOIN OT_Convenio con  (NOLOCK)
				ON sol.IdOTSolicitud = con.IdOTSolicitud  
			INNER JOIN AP_Usuario ap  (NOLOCK)
				ON ap.Usuario = RTRIM(@pUsuario)
			INNER JOIN [dbo].[AP_UsuarioCentroCosto] ucc  (NOLOCK)
				ON ap.UsuarioID  = ucc.IdUsuario 
				   AND sol.IdCentroCosto = ucc.IdCentroCosto 
			INNER JOIN AP_PerfilUsuario pu  (NOLOCK)
				ON ap.UsuarioID = pu.UsuarioID  
			INNER JOIN AP_Perfil per (NOLOCK)
				ON pu.PerfilID = per.IdPerfil 
				   AND subC.IdContrato = per.IdContrato 
			INNER JOIN Petrovendor.dbo.S_Usuario upet (NOLOCK)
				ON ap.Usuario COLLATE DATABASE_DEFAULT = upet.Correo COLLATE DATABASE_DEFAULT 
			LEFT JOIN Petrovendor.dbo.MM_Pedido ped (NOLOCK)
				ON  subC.IdPedido = ped.IdPedido
			LEFT JOIN Petrovendor.dbo.[PV_TipoMoneda] mon (NOLOCK)
				ON ped.IdMoneda = mon.IdMoneda  
		WHERE ISNULL(sol.IsActivo, 0) = 1
			  AND ISNULL(sol.IsEliminado, 0) = 0
			  AND con.Aprobada = @pAprobada
			  AND subC.IdContrato=@IdContrato
		ORDER BY con.IdOTConvenio DESC;
	END

END