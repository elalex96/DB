if exists(select * from sys.procedures where name = 'SP_AD_S3_MM_PeticionOfertaADAdjunto')
begin
	drop proc SP_AD_S3_MM_PeticionOfertaADAdjunto
end

go
-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
CREATE  PROCEDURE [dbo].[SP_AD_S3_MM_PeticionOfertaADAdjunto] 
    -- Add the parameters for the stored procedure here
    @ACCION NVARCHAR(MAX),
    @IdDocumento INT = NULL,
    @Mime NVARCHAR(MAX) = NULL,
    @Carpeta NVARCHAR(MAX) = NULL,
    @Extension NVARCHAR(MAX) = NULL,
    @IdentificadorS3 NVARCHAR(MAX) = NULL,
    @NombreDocumento NVARCHAR(MAX) = NULL,
	@IdSolicitudPedido INT = NULL,
	@Bucket nvarchar(max) = NULL
AS
BEGIN


    IF @ACCION = 'CONSULTAR'
    BEGIN

        SELECT TOP 50
            D.IdPeticionOferta,                                                                           --0
            '' AS Documento,                                                                              --1
            CONCAT('Adjunto adjudicacion unica', ' ', D.IdSolicitudPedido, '.pdf') AS NombreTipoDocumento, --2	
			D.IdSolicitudPedido	 
        FROM dbo.MM_PeticionOferta D
        WHERE AMS3 IS NULL
              AND LEN(D.DocAdjudicacionDirecta) > 0
        ORDER BY D.IdPeticionOferta ASC;

    END;

    IF @ACCION = 'CONSULTAR_DOCUMENTO'
    BEGIN

        SELECT DocAdjudicacionDirecta
        FROM dbo.MM_PeticionOferta
        WHERE IdPeticionOferta = @IdDocumento;

    END;


    IF @ACCION = 'ACTUALIZAR'
    BEGIN
        BEGIN TRAN tran1;
        BEGIN TRY

            INSERT INTO dbo.MM_PeticionOfertaADAdjunto
            (
                IdInvitacion,
                IdPeticionOferta,
                Descripcion,
                Carpeta,
                Identificador,
                Mime,
                Extension,
                NombreDocumento,
                Activo,
				IdSolicitudPedido,
				Bucket
            )
            VALUES
            (   NULL,                -- IdInvitacion - int
                @IdDocumento,     -- IdPeticioOferta - int
                '',               -- Descripcion - nvarchar(max)
                @Carpeta,         -- Carpeta - nvarchar(max)
                @IdentificadorS3, -- Identificador - nvarchar(max)
                @Mime,            -- Mime - nvarchar(max)
                @Extension,       -- Extension - nvarchar(max)
                @NombreDocumento,	-- NombreDocumento - nvarchar(max)
                1,					-- Activo - bit    			    
				@IdSolicitudPedido, --IdSolicitudPedido  - int
				@Bucket
                );

            UPDATE dbo.MM_PeticionOferta
            SET AMS3 = 1
            WHERE IdPeticionOferta = @IdDocumento;

            COMMIT TRAN tran1;
        END TRY
        BEGIN CATCH
            ROLLBACK TRAN tran1;

            SELECT 'ERROR_PROCESO',
                   ERROR_NUMBER() AS ErrorNumber,
                   ERROR_SEVERITY() AS ErrorSeverity,
                   ERROR_STATE() AS ErrorState,
                   ERROR_PROCEDURE() AS ErrorProcedure,
                   ERROR_LINE() AS ErrorLine,
                   ERROR_MESSAGE() AS ErrorMessage;
        END CATCH;
    END;


END;
