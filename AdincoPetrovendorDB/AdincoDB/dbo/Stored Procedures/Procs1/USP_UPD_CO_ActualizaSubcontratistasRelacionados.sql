IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_UPD_CO_ActualizaSubcontratistasRelacionados'
    )
    DROP PROCEDURE USP_UPD_CO_ActualizaSubcontratistasRelacionados;
GO
CREATE PROCEDURE [dbo].[USP_UPD_CO_ActualizaSubcontratistasRelacionados]
@IdUsuario            INT = 0,
@IdContrato            INT,
@IdContratista            INT,
@IdRelacionEmpresas            INT,
@IdSubcontratista           INT,
@Activo            bit
AS
    BEGIN

	UPDATE CO_RelacionEmpresas
	SET Activo = @Activo,
	ModificadoPor = @IdUsuario,
	ModificadoEl	=	GETDATE()
	WHERE 
		IdRelacionEmpresas = @IdRelacionEmpresas;

	SELECT * FROM CO_RelacionEmpresas (NOLOCK) WHERE IdRelacionEmpresas = @IdRelacionEmpresas;
	END;