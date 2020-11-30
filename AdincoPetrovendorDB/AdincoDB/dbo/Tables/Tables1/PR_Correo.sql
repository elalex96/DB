CREATE TABLE [dbo].[PR_Correo] (
    [No_correo]    INT            NULL,
    [Remitente]    NCHAR (50)     NULL,
    [Display]      NVARCHAR (50)  NULL,
    [Destinatario] NCHAR (50)     NULL,
    [Copia_]       NCHAR (50)     NULL,
    [Titulo]       NCHAR (50)     NULL,
    [Cuerpo]       NVARCHAR (MAX) NULL,
    [Entrada]      DATETIME       NULL,
    [Status]       INT            CONSTRAINT [DF_admin_correo_status] DEFAULT ((0)) NULL,
    [Sistema_]     NCHAR (30)     NULL,
    [Attach_]      NCHAR (100)    NULL,
    [attach_2]     NVARCHAR (MAX) NULL,
    [Id]           INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [d2]           NVARCHAR (50)  NULL,
    [d3]           NVARCHAR (50)  NULL,
    [d4]           NVARCHAR (50)  NULL,
    CONSTRAINT [PK_PR_admin_correo] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

