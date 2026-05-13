
-- ================================================================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	14 de Febrero del 2023
-- Descripción:			Se actualiza el estatus del proceso de la obtencion de archivos 
-- ================================================================================
CREATE PROCEDURE [dbo].[SP_EMP_ActualizarEstatusSolicitudDescargaArchivo]
	@Id INT,
	@ContratoId INT,
	@Carpeta NVARCHAR(1000),
	@UUID NVARCHAR(1000),
	@NombreArchivo NVARCHAR(1000),
	@Size FLOAT,
	@Meta NVARCHAR(1000)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE EMP_SolicitudDescargaArchivos
	SET Carpeta = @Carpeta,
		UUIDAmazon = @UUID,
		NombreArchivo = @NombreArchivo,
		Size = @Size,
		Meta = @Meta,
		FechaProcesado = GETDATE(),
		Procesado = 1
	WHERE Id = @Id
		AND ContratoId = @ContratoId;

	SELECT Procesado
	FROM EMP_SolicitudDescargaArchivos (NOLOCK)
	WHERE Id = @Id
		AND ContratoId = @ContratoId;
END