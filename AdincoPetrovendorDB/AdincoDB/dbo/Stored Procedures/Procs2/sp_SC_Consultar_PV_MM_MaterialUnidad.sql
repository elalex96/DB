USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_Consultar_PV_MM_MaterialUnidad'
)
    DROP PROCEDURE sp_SC_Consultar_PV_MM_MaterialUnidad; 
	GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_ConsultarOT_Estatus]    Script Date: 10/07/2023 11:02:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================
CREATE Proc [dbo].[sp_SC_Consultar_PV_MM_MaterialUnidad]
	@ContratoId			int,
	@UsuarioId		int	
As
begin
	
	SELECT NombreUnidad = Unidad,
	idUnidad 
	FROM Petrovendor.dbo.[PV_MM_MaterialUnidad] (NOLOCK) 
	order by uNIDAD ASC

end