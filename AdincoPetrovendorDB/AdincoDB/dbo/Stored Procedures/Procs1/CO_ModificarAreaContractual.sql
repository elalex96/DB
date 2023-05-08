-- ====================================================================
CREATE PROCEDURE [dbo].[CO_ModificarAreaContractual]
	-- Add the parameters for the stored procedure here
	@IdAreaContractualPemex AS NVARCHAR(MAX),
	@NombreAreaContractual AS NVARCHAR(MAX),
	@Descripcion AS NVARCHAR(MAX),
	@SuperficieKm2 AS FLOAT,
	@IdRegion AS INT,
	@Activo AS BIT,
	@IdActivo AS INT,
	@IdUbicacionAC AS INT,
	@IdEstado AS INT,
	@IdAreaContractual AS INT,
	@idContrato AS INT,
	@idUsuario AS INT
AS
BEGIN
	-- =================================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 03/01/2019
	-- Description:	Modificación de datos en la tabla CO_AreaContractual
	-- =================================================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	UPDATE CO_AreaContractual 
	SET IdAreaContractualPemex = @IdAreaContractualPemex,
		NombreAreaContractual = @NombreAreaContractual,
		Descripcion = @Descripcion,
		SuperficieKm2 = @SuperficieKm2,
		IdRegion = @IdRegion,
		Activo = @Activo,
		IdActivo = @IdActivo,
		IdUbicacionAC = @IdUbicacionAC,
		IdEstado = @IdEstado
	WHERE IdAreaContractual = @IdAreaContractual;
END
