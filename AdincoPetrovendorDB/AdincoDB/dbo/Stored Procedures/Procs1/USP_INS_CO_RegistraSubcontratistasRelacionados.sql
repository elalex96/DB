
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_RegistraSubcontratistasRelacionados'
    )
    DROP PROCEDURE USP_INS_CO_RegistraSubcontratistasRelacionados;
GO
CREATE PROCEDURE [dbo].[USP_INS_CO_RegistraSubcontratistasRelacionados]
@IdUsuario            INT = 0,
@IdContrato            INT,
@IdContratista            INT,
@IdSubcontratistas CO_Type_IdSubcontratistas READONLY
AS
BEGIN

	INSERT INTO CO_RelacionEmpresas
	(
	IdContratista,
	IdRelacionada,
	CreadoPor,
	CreadoEl,
	Activo)
	SELECT 
		@IdContratista,
		IdSubContratista,
		@IdUsuario,
		GETDATE(),
		1
    FROM @IdSubcontratistas;

	SELECT * FROM CO_RelacionEmpresas (NOLOCK) WHERE IdContratista = @IdContratista;
END;

