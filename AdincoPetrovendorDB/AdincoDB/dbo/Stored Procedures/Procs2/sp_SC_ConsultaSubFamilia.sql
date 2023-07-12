USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultaSubFamilia'
)
    DROP PROCEDURE sp_SC_ConsultaSubFamilia; 
	GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_ConsultaSubFamilia]    Script Date: 10/07/2023 09:47:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================|
CREATE PROC [dbo].[sp_SC_ConsultaSubFamilia]
	@ContratoId		int,
	@UsuarioId		int	
AS
SET NOCOUNT ON;
select t1.IdSubFamilia,
		t1.CodSubFamilia,
		t1.SubFamilia			
from Petrovendor.[dbo].[PV_MM_MaterialSubFamilia] t1 (NOLOCK)
join Petrovendor.dbo.[MM_Maestro] t2  (NOLOCK)
	on t1.IdSubFamilia = t2.IdSubFamilia
where t1.isactivo = 1 and
	t1.iseliminado = 0 and
	t2.IdTipoCatalogoMaestro = 2 --> cte
group by t1.IdSubFamilia,
		t1.CodSubFamilia,
		t1.SubFamilia		
order by SubFamilia