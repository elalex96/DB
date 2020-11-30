-- =================================================================
CREATE PROCEDURE [dbo].[CO_InsertarAreaContractual] 
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
	@idContrato AS INT,
	@idUsuario AS INT
AS
BEGIN
	-- ==============================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 03/01/2019
	-- Description:	Inserción de datos en la tabla CO_AreaContractual
	-- ==============================================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for procedure here
	INSERT INTO CO_AreaContractual (
		IdAreaContractualPemex, 
		NombreAreaContractual, 
		Descripcion, 
		SuperficieKm2, 
		IdRegion, 
		Activo, 
		IdActivo, 
		IdUbicacionAC, 
		IdEstado,
		CreadoPor)
	VALUES (
		@IdAreaContractualPemex, 
		@NombreAreaContractual, 
		@Descripcion, 
		@SuperficieKm2, 
		@IdRegion, 
		@Activo, 
		@IdActivo, 
		@IdUbicacionAC, 
		@IdEstado,
		@idUsuario)
END
