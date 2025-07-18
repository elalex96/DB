
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenSubcontratistasFaltantesPorRelacionar'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenSubcontratistasFaltantesPorRelacionar;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenSubcontratistasFaltantesPorRelacionar]
 @IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdContratista            INT
AS
    BEGIN
					SELECT 
						PV_Subcontratista.IdSubcontratista,
						PV_Subcontratista.RazonSocial,
						PV_Subcontratista.RFC,
						CO_RelacionEmpresas.IdRelacionEmpresas
					FROM 
						PV_Subcontratista (NOLOCK)
					LEFT JOIN
						CO_RelacionEmpresas (NOLOCK)
						ON	PV_Subcontratista.IdSubcontratista	=	CO_RelacionEmpresas.IdRelacionada
						AND CO_RelacionEmpresas.IdContratista = @IdContratista
					WHERE 
						CO_RelacionEmpresas.IdRelacionEmpresas IS NULL
					ORDER BY  RazonSocial ASC
END