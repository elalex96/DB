CREATE TABLE [dbo].[JA_Participantes] (
    [CorreoParticipanteExterno] NVARCHAR (200) NULL,
    [CreadoPor]                 INT            NULL,
    [FechaCreado]               SMALLDATETIME  NULL,
    [IdParticipante]            INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]               INT            NULL,
    [IdUsuario]                 INT            NULL,
    [NombreParticipante]        NVARCHAR (150) NULL,
    [Activo]                    BIT            NULL
);

