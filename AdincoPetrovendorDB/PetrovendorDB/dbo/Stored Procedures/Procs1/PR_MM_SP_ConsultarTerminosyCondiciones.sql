USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'PR_MM_SP_ConsultarTerminosyCondiciones'
)
DROP PROCEDURE PR_MM_SP_ConsultarTerminosyCondiciones;
GO
/****** Object:  StoredProcedure [dbo].[PR_MM_SP_ConsultarTerminosyCondiciones]    Script Date: 26/08/2022 02:59:26 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <26-07-2019>
-- Description:	<Se agrego la funcion de mostrar los TC cuando se crea la operacion>
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[PR_MM_SP_ConsultarTerminosyCondiciones]
	@IdDocumento int
AS
BEGIN
			
	SELECT
		TC.Nombre,
		ISNULL(TCO.TerminosCondicionesTexto,TC.Documento)
	FROM dbo.TA_TerminosCondicionesOperacion AS TCO (NOLOCK)
	LEFT JOIN dbo.TC_TerminosYCondicionesDocV2 AS TC  (NOLOCK)
		ON TCO.IdTerminosYCondiciones = TC.IdTerminosYCondiciones
	WHERE TCO.IdOperacion = @IdDocumento;	
	
END