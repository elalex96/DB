USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultarSubContrato'
)
    DROP PROCEDURE sp_SC_ConsultarSubContrato; 
	GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_ConsultarSubContrato]    Script Date: 10/07/2023 11:02:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================
CREATE Proc [dbo].[sp_SC_ConsultarSubContrato]
	@ContratoId			int,
	@UsuarioId		int	
As
begin
	SET NOCOUNT ON;
	SELECT IdSubContrato, NumeroSubContrato
	FROM [SC_SubContrato]  (NOLOCK)
	where isActivo = 1 
	and isEliminado = 0 
	order by NumeroSubContrato ASC

end
