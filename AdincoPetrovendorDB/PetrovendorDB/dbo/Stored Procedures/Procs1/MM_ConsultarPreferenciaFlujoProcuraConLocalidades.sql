USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_ConsultarPreferenciaFlujoProcuraConLocalidades'
)
    DROP PROCEDURE MM_ConsultarPreferenciaFlujoProcuraConLocalidades;
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultarDocumentosXMaterialSolped]    Script Date: 28/08/2023 03:57:11 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel AC
-- Create date: <04-09-2023>
-- Description:	Validar si contrato actual tiene al preferencia FlujoProcuraConLocalidades
-- =============================================
CREATE PROCEDURE [dbo].[MM_ConsultarPreferenciaFlujoProcuraConLocalidades] 
@IdProveedor INT ,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN	
					
		
		SELECT PC.Id, PC.ContratoId, PreferenciaId, PC.Valor, PC.Activo 
		FROM AP_Preferencias P (NOLOCK)
		JOIN AP_PreferenciaContrato PC (NOLOCK)
			ON P.Id = PC.PreferenciaId
		WHERE PC.ContratoId = @IdContrato
		AND PC.Activo = 1
		AND P.Activo = 1
		AND P.Nombre ='FlujoProcuraConLocalidades' --> CTE EN TABLA AP_Preferencias


	END