USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultarOT_Estatus'
)
    DROP PROCEDURE sp_SC_ConsultarOT_Estatus; 
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
CREATE Proc [dbo].[sp_SC_ConsultarOT_Estatus]
	@ContratoId			int,
	@UsuarioId		int	
As
begin
	SET NOCOUNT ON;
	SELECT IdOtEstatus, Descripcion
	FROM dbo.OT_Estatus (NOLOCK)
	ORDER BY Descripcion ASC

end
