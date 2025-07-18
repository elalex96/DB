
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenSubcontratistasRelacionados'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenSubcontratistasRelacionados;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenSubcontratistasRelacionados]--1,1,2
 @IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdContratista            INT
AS
    BEGIN
			SELECT DISTINCT 
				IdRelacionEmpresas,
				IdSubcontratista,
				RFC,
				RazonSocial,
				ISNULL(AP_Usuario.Nombre,'')  AS	CreadoPor,
				CO_RelacionEmpresas.CreadoEl,
				ISNULL(AP_UsuarioMod.Nombre,'')  ModificadoPor,
				CO_RelacionEmpresas.ModificadoEl,
				ISNULL(CO_RelacionEmpresas.Activo,0) AS Activo
				FROM 
					CO_RelacionEmpresas (NOLOCK)
				JOIN
					PV_Subcontratista(NOLOCK)
					ON CO_RelacionEmpresas.IdRelacionada = PV_Subcontratista.IdSubcontratista
				LEFT JOIN
					AP_Usuario (NOLOCK)
					on	CO_RelacionEmpresas.CreadoPor	=	AP_Usuario.UsuarioID
				LEFT JOIN
					AP_Usuario AS AP_UsuarioMod (NOLOCK)
					on	CO_RelacionEmpresas.ModificadoPor	=	AP_UsuarioMod.UsuarioID
				WHERE 
					IdContratista = @IdContratista
				ORDER BY  RazonSocial ASC
	END;
