USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MPY_GuardarDocumentoPRESES'
)
    DROP PROCEDURE SP_MPY_GuardarDocumentoPRESES;
/****** Object:  StoredProcedure [dbo].[SP_MPY_GuardarDocumentoPRESES]    Script Date: 28/07/2021 01:25:49 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 30/10/2018
-- Description:	se guardan el documento para PRE-SES
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 28-07-2021
-- Description:	Se agrega parametro de bucket
-- ============================================= 
CREATE procedure [dbo].[SP_MPY_GuardarDocumentoPRESES]
	-- Add the parameters for the stored procedure here
	@IdPRESES INT,
	@IdTipoDocumento INT,
	@NombreDoc VARCHAR(100),
	@Carpeta NVARCHAR(300),
	@Identificador NVARCHAR(300),
	@Extension NVARCHAR(300),
	@Mime NVARCHAR(300),
	@Bucket NVARCHAR(300),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO Adinco.dbo.MPY_DocumentosPRESES
	(
	    IdPRESES,
	    IdTipoDocumento,
	    NombreDoc,
	    Carpeta,
	    Identificador,
	    Extension,
	    Mime,
	    Activo,
	    CreadoPor,
	    CreadoEl,
		Bucket
	)
	VALUES
	(   @IdPRESES,         -- IdPRESES - int
	    @IdTipoDocumento,         -- IdTipoDocumento - int
	    @NombreDoc,        -- NombreDoc - varchar(100)
	    @Carpeta,       -- Carpeta - nvarchar(300)
	    @Identificador,       -- Identificador - nvarchar(300)
	    @Extension,       -- Extension - nvarchar(300)
	    @Mime,       -- Mime - nvarchar(300)
	    1,      -- Activo - bit
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
		@Bucket
	    )

	SELECT @@IDENTITY

END
